//
//  CircularBuffer+AudioBufferList.swift
//  ChordFinder
//
//  Created by Jason Cardwell on 12/15/20.
//  Copyright © 2020 Moondeer Studios. All rights reserved.
//
import Foundation
import Darwin
import Accelerate
import AudioToolbox

// MARK: - AudioBufferList

/// Lazily instantiated global used for adjusting `AudioTimeStamp` values.
private let secondsToHostTicks: Double = {
  var tinfo = mach_timebase_info_data_t()
  mach_timebase_info(&tinfo);
  return 1.0 / (Double(tinfo.numer) / Double(tinfo.denom) * 1.0e-9)
}()

/// 16-byte aligns the specified pointer.
///
/// - Parameter pointer: The pointer for which to ensure 16-byte alignment.
/// - Returns: The original pointer or the next aligned address in memory.
private func align16Byte(_ pointer: UnsafeMutableRawPointer) -> UnsafeMutableRawPointer {

  guard let alignedPointer =
          UnsafeMutableRawPointer(bitPattern: align16Byte(Int(bitPattern: pointer)))
  else
  {
    fatalError("\(#fileID) \(#function) Failed to get aligned pointer. ")
  }

  return alignedPointer

}

/// 16-byte aligns the specified pointer.
///
/// - Parameter address: The memory address to align.
/// - Returns: `address` if already aligned or the next aligned address in memory.
private func align16Byte(_ address: Int) -> Int {

 return (address & (16 - 1) != 0)
  ? address + (16 - (address & (16 - 1)))
  : address

}

extension CircularBuffer {

  /// The block header structure used to store audio buffer lists on the buffer.
  struct ABLBlockHeader {

    /// The timestamp for the buffer list.
    var timestamp: AudioTimeStamp

    /// The total number of bytes used by the block.
    var totalLength: UInt32

    /// The audio buffer list.
    var bufferList: AudioBufferList

  }

  /// Prepare an empty buffer list, stored on the circular buffer
  ///
  /// - Parameters:
  ///   - numberOfBuffers: The number of buffers to be contained within the buffer list
  ///   - bytesPerBuffer: The number of bytes to store for each buffer
  ///   - timestamp: The timestamp associated with the buffer, or `nil`. Note that you
  ///                can also pass a timestamp into `produceAudioBufferList`, to set it
  ///                there instead.
  /// - Returns: The empty buffer list, or `nil` if circular buffer has insufficient space.
  func prepareEmptyAudioBufferList(
    numberOfBuffers: Int,
    bytesPerBuffer: Int,
    timestamp: AudioTimeStamp?) -> UnsafeMutablePointer<ABLBlockHeader>?
  {

    // Calculate the number of bytes required for storing the new buffer list.
    let bytesRequired = MemoryLayout<ABLBlockHeader>.size
                      + MemoryLayout<AudioToolbox.AudioBuffer>.size * (numberOfBuffers - 1)
                      + numberOfBuffers * bytesPerBuffer

    // Get a pointer to the head byte and check that their is space in the buffer.
    guard let (block, availableBytes) = head(), availableBytes >= bytesRequired else {
      return nil
    }

    assert(Int(bitPattern: block) & 0xF == 0,
           "\(#fileID) \(#function) Expected `block` to be 16-byte aligned.")

    // Zero out the bytes for the block.
    memset(block, 0, bytesRequired)

    // Bind the memory for the block header.
    let boundBlock = block.bindMemory(to: ABLBlockHeader.self, capacity: 1)
//    var boundBlock = block.load(as: ABLBlockHeader.self)

    // Insert the timestamp
    boundBlock.pointee.timestamp = timestamp ?? AudioTimeStamp()

    // Create the list.
    boundBlock.pointee.bufferList = AudioBufferList()
    boundBlock.pointee.bufferList.mNumberBuffers = UInt32(numberOfBuffers)

    // Wrap the buffer list.
    let bufferListPointer =
      UnsafeMutableAudioBufferListPointer(&boundBlock.pointee.bufferList)

    var totalLength: UInt32 = 0

    // Calculate the offset for the audio buffer data.
    let offset = MemoryLayout<AudioBufferList>.size
               + (numberOfBuffers - 1) * MemoryLayout<AudioBuffer>.size

    // Create a pointer to the first byte for the audio buffer data.
    var dataPointer = block + offset

    // Iterate buffer indices.
    for bufferIndex in 0..<numberOfBuffers {

      // Ensure the data pointer is 16-byte aligned.
      dataPointer = align16Byte(dataPointer)

      // Ensure there is enough memory for the buffers.
      guard (Int(bitPattern: dataPointer)
              + bytesPerBuffer
              - Int(bitPattern: block)) <= availableBytes
      else
      {
        return nil
      }

      // Initialize the audio buffer at `bufferIndex` with the aligned pointer.
      bufferListPointer[bufferIndex].mData = dataPointer
      bufferListPointer[bufferIndex].mDataByteSize = UInt32(bytesPerBuffer)
      bufferListPointer[bufferIndex].mNumberChannels = 1

      // Advance the pointer by the number of bytes per buffer.
      dataPointer += bytesPerBuffer

    }

    // Make sure whole buffer (including timestamp and length value)
    // is 16-byte aligned in length
    totalLength = UInt32(align16Byte(Int(bitPattern: dataPointer)
                                      - Int(bitPattern: block)))

    boundBlock.pointee.totalLength = totalLength

    guard totalLength <= availableBytes else { return nil }

    return boundBlock

  }


  /// Prepare an empty buffer list, stored on the circular buffer, using an audio
  /// description to automatically configure buffer
  ///
  /// - Parameters:
  ///   - format: The kind of audio that will be stored.
  ///   - frameCount: The number of frames that will be stored.
  ///   - timestamp: The timestamp associated with the buffer, or `nil`. Note that you
  ///                can also pass a timestamp into `produceAudioBufferList`, to set it
  ///                there instead.
  /// - Returns: The empty buffer list, or `nil` if the buffer has insufficient space.
  func prepareEmptyAudioBufferList(
    format: AudioStreamBasicDescription,
    frameCount: AVAudioFrameCount,
    timestamp: AudioTimeStamp?) -> UnsafeMutablePointer<ABLBlockHeader>?
  {
    prepareEmptyAudioBufferList(
      numberOfBuffers: format.mFormatFlags & kAudioFormatFlagIsNonInterleaved != 0
                       ? Int(format.mChannelsPerFrame)
                       : 1,
      bytesPerBuffer: Int(format.mBytesPerFrame * frameCount),
      timestamp: timestamp)
  }

  /// This marks the audio buffer list prepared using `prepareEmptyAudioBufferList`
  /// as ready for reading. You must not call this function without first calling
  /// `prepareEmptyAudioBufferList`.
  ///
  /// - Parameter timestamp: The timestamp associated with the buffer, or `nil` to
  ///                        leave as-is. Note that you can also pass a timestamp
  ///                        into `prepareEmptyAudioBufferList`, to set it there instead.
  mutating func produceAudioBufferList(timestamp: AudioTimeStamp?) {

    guard let (block, availableBytes) = head() else {
      fatalError("\(#fileID) \(#function) Failed to acquire head byte.")
    }

    assert(Int(bitPattern: block) & 0xF == 0,
           "\(#fileID) \(#function) Expected `block` to be 16-byte aligned.")

    var boundBlock = block.load(as: ABLBlockHeader.self)

    if let timestamp = timestamp { boundBlock.timestamp = timestamp }

    withUnsafeMutablePointer(to: &boundBlock.bufferList) {
      let bufferListPointer = UnsafeMutableAudioBufferListPointer($0)
      guard let mData = bufferListPointer.last?.mData,
            let mDataByteSize = bufferListPointer.last?.mDataByteSize
      else
      {
        fatalError("\(#fileID) \(#function) Failed to retrieve last audio buffer.")
      }

      let calculatedLength = UInt32(align16Byte(Int(bitPattern: mData)
                                                  + Int(mDataByteSize)
                                                  - Int(bitPattern: block)))


      assert(calculatedLength <= boundBlock.totalLength
              && Int(calculatedLength) <= availableBytes,
             "\(#fileID) \(#function) Calculated length is greater than expected.")

      boundBlock.totalLength = calculatedLength

    }

    produce(amount: Int(boundBlock.totalLength))

  }

  /// Copy the audio buffer list onto the buffer
  ///
  /// - Parameters:
  ///   - list: Buffer list containing audio to copy to buffer
  ///   - timestamp: The timestamp associated with the buffer, or `nil`
  ///   - frames: Length of audio in frames. Specify `AVAudioFrameCount.max` to copy the
  ///             whole buffer (audioFormat can be `nil`, in this case)
  ///   - format: The `AudioStreamBasicDescription` describing the audio, or `nil`
  ///             if `AVAudioFrameCount.max` specified for the `frames` argument.
  /// - Returns: `true` if buffer list was successfully copied; `false` otherwise.
  @discardableResult
  mutating func copy(audioBufferList list: UnsafeMutablePointer<AudioBufferList>,
                     timestamp: AudioTimeStamp?,
                     frames: AVAudioFrameCount = AVAudioFrameCount.max,
                     format: AudioStreamBasicDescription?) -> Bool
  {
    // Return `true` if the request was for copying `0` frames.
    guard frames > 0 else { return true }

    var byteCount = list.pointee.mBuffers.mDataByteSize

    if frames != AVAudioFrameCount.max {

      guard let format = format else { return false }

      byteCount = frames * format.mBytesPerFrame

      assert(byteCount <= list.pointee.mBuffers.mDataByteSize,
             "\(#fileID) \(#function) Unexpected byte count.")

    }

    guard byteCount > 0 else { return true }

    guard let blockHeader = prepareEmptyAudioBufferList(
            numberOfBuffers: Int(list.pointee.mNumberBuffers),
            bytesPerBuffer: Int(byteCount),
            timestamp: timestamp)
    else
    {
      return false
    }



    let bufferListPointer =
      UnsafeMutableAudioBufferListPointer(&blockHeader.pointee.bufferList)
    let listPointer = UnsafeMutableAudioBufferListPointer(list)

    for bufferIndex in 0..<bufferListPointer.count {

      guard let bufferMData = bufferListPointer[bufferIndex].mData,
            let listMData = listPointer[bufferIndex].mData
      else
      {
        fatalError("\(#fileID) \(#function) Failed to get `mData`.")
      }

      memcmp(bufferMData, listMData, Int(byteCount))

    }

    produceAudioBufferList(timestamp: nil)

    return true

  }

  /// Copy the audio buffer onto the circular buffer.
  ///
  /// - Parameters:
  ///   - buffer: `AVAudioPCMBuffer` containing audio to copy to buffer
  ///   - timestamp: The timestamp associated with the buffer, or `nil`
  ///   - frames: Length of audio in frames. Specify `AVAudioFrameCount.max` to copy the
  ///             whole buffer (audioFormat can be `nil`, in this case)
  /// - Returns: `true` if buffer list was successfully copied; `false` otherwise.
  @discardableResult
  mutating func copy(buffer: AVAudioPCMBuffer,
                     timestamp: AVAudioTime?,
                     frames: AVAudioFrameCount = AVAudioFrameCount.max) -> Bool
  {
    return copy(audioBufferList: buffer.mutableAudioBufferList,
                timestamp: timestamp?.audioTimeStamp,
                frames: frames,
                format: buffer.format.streamDescription.pointee)
  }

  /// The next stored buffer list.
  ///
  /// - Returns: The next buffer list in the buffer and it's timestamp
  func nextBufferList() -> (UnsafeMutablePointer<AudioBufferList>, AudioTimeStamp)? {

    guard let (block, _) = tail() else { return nil }

    var boundBlock = block.load(as: ABLBlockHeader.self)
    let listPointer = UnsafeMutableAudioBufferListPointer(&boundBlock.bufferList)

    return (listPointer.unsafeMutablePointer, boundBlock.timestamp)

  }

  /// The next stored buffer list after the given one.
  ///
  /// - Parameter list: Preceding buffer list
  /// - Returns: The next buffer list and its timestamp or `nil`.
  func nextBufferList(after list: UnsafeMutablePointer<AudioBufferList>)
  -> (UnsafeMutablePointer<AudioBufferList>, AudioTimeStamp)?
  {

    guard let (tailByte, availableBytes) = tail() else {
      return nil
    }

    let lastByte = tailByte + availableBytes

    assert(Int(bitPattern: list) > Int(bitPattern: tailByte)
            && Int(bitPattern: list) < Int(bitPattern: lastByte),
           "\(#fileID) \(#function) Unexpected audio buffer list memory address.")

    guard let nextBlockByte = withUnsafeBytes(of: list, {
      listBytes -> UnsafeRawPointer? in
      guard let baseByte = listBytes.baseAddress else {
        logw("\(#fileID) \(#function) Unable to get base address.")
        return nil
      }

      guard let offset =
              MemoryLayout<ABLBlockHeader>.offset(of: \ABLBlockHeader.bufferList)
      else
      {
        logw("\(#fileID) \(#function) Unable to calculate offset.")
        return nil
      }

      let blockHeadByte = baseByte - offset
      assert(Int(bitPattern: blockHeadByte) & 0xF == 0) /* Beware unaligned accesses */

      let originalBlock = blockHeadByte.assumingMemoryBound(to: ABLBlockHeader.self)
      let nextBlockByte = blockHeadByte + Int(originalBlock.pointee.totalLength)

      guard Int(bitPattern: nextBlockByte) < Int(bitPattern: lastByte) else {
        logw("\(#fileID) \(#function) Next block is past the end.")
        return nil
      }

      assert(Int(bitPattern: nextBlockByte) & 0xF == 0) /* Beware unaligned accesses */

      return nextBlockByte

    }) else { return nil }

    var nextBlock = nextBlockByte.load(as: ABLBlockHeader.self)
    let nextList = UnsafeMutableAudioBufferListPointer(&nextBlock.bufferList)

    return (nextList.unsafeMutablePointer, nextBlock.timestamp)

  }

  /// Consume the next buffer list.
  mutating func consumeNextBufferList() {

    guard let (block, _) = tail() else { return }

    consume(amount: Int(block.load(as: ABLBlockHeader.self).totalLength))

  }

  /// Consume the next buffer list
  ///
  /// This will also increment the sample time and host time portions of the timestamp of
  /// the buffer list, if present.
  ///
  /// - Parameters:
  ///   - framesToConsume: The number of frames to consume from the buffer list
  ///   - format: The `AudioStreamBasicDescription` describing the audio.
  mutating func consumeNextBufferListPartial(framesToConsume: Int,
                                             format: AudioStreamBasicDescription)
  {

    assert(framesToConsume >= 0)

    guard let (block, _) = tail() else { return }

    assert(Int(bitPattern: block) & 0xF == 0) /* Beware unaligned accesses */

    var boundBlock = block.load(as: ABLBlockHeader.self)
    let bufferList = UnsafeMutableAudioBufferListPointer(&boundBlock.bufferList)
    let bytesToConsume = min(Int(format.mBytesPerFrame) * framesToConsume,
                             Int(bufferList[0].mDataByteSize))


    guard bytesToConsume != Int(bufferList[0].mDataByteSize) else {
      consumeNextBufferList()
      return
    }

    for bufferIndex in 0..<bufferList.count {

      assert(bytesToConsume <= bufferList[bufferIndex].mDataByteSize)

      guard let mData = bufferList[bufferIndex].mData else { continue }

      bufferList[bufferIndex].mData = mData + bytesToConsume
      bufferList[bufferIndex].mDataByteSize -= UInt32(bytesToConsume)

    }

    if boundBlock.timestamp.mFlags.contains(.sampleTimeValid) {
      boundBlock.timestamp.mSampleTime += Double(framesToConsume)
    }

    if boundBlock.timestamp.mFlags.contains(.hostTimeValid) {
      boundBlock.timestamp.mHostTime += UInt64((Double(framesToConsume)
                                                  / format.mSampleRate)
                                                * secondsToHostTicks)
    }

    // Reposition block forward, just before the audio data, ensuring 16-byte alignment
    let bitPattern = UInt(bitPattern: block + bytesToConsume) & ~0xF
    guard let newBlock = UnsafeMutableRawPointer(bitPattern: bitPattern) else {
      fatalError("\(#fileID) \(#function) Failed to get new block pointer.")
    }

    let size = MemoryLayout<ABLBlockHeader>.size
             + ((bufferList.count - 1) * MemoryLayout<AudioBuffer>.size)

    memmove(newBlock, block, size)

    let bytesFreed = Int(bitPattern: newBlock) - Int(bitPattern: block)

    newBlock.assumingMemoryBound(to: ABLBlockHeader.self)
      .pointee.totalLength -= UInt32(bytesFreed)

    consume(amount: bytesFreed)

  }

  /// Consume a certain number of frames from the buffer, possibly from multiple queued
  /// buffer lists
  ///
  /// Copies the given number of frames from the buffer into `list`, of the given audio
  /// description, then consumes the audio buffers. If an audio buffer has not been
  /// entirely consumed, then updates the queued buffer list structure to point to the
  /// unconsumed data only.
  ///
  /// - Parameters:
  ///   - count: On input, the number of frames in the given audio format to consume;
  ///            on output, the number of frames provided.
  ///   - list: The buffer list to copy audio to, or `nil` to discard audio. If not `nil`,
  ///           the structure must be initialised properly, and the mData pointers must
  ///           not be `nil`.
  ///   - timestamp: On output, if not `nil`, the timestamp corresponding to the first
  ///                audio frame returned.
  ///   - format: The format of the audio stored in the buffer.
  @discardableResult
  mutating func dequeueBufferListFrames(count: UInt32,
                                        list: UnsafeMutablePointer<AudioBufferList>?,
                                        format: AudioStreamBasicDescription)
  -> (Int, AudioTimeStamp)?
  {

    var timestamp: AudioTimeStamp?
    var bytesToGo = count * format.mBytesPerFrame
    var bytesCopied = UInt32()

    while bytesToGo > 0 {

      guard let (dequeuedList, timestampʹ) = nextBufferList() else { break }

      if timestamp == nil { timestamp = timestampʹ }

      let dequeuedListPointer = UnsafeMutableAudioBufferListPointer(dequeuedList)

      let bytesToCopy = min(bytesToGo, dequeuedListPointer[0].mDataByteSize)

      if let list = list {

        let listPointer = UnsafeMutableAudioBufferListPointer(list)

        for bufferIndex in 0..<listPointer.count {

          assert(bytesCopied + bytesToCopy <= listPointer[bufferIndex].mDataByteSize)
          guard let mData = listPointer[bufferIndex].mData,
                let dequeuedMData = dequeuedListPointer[bufferIndex].mData
          else
          {
            continue
          }

          memcpy(mData + Int(bytesCopied), dequeuedMData, Int(bytesToCopy))

        }

      }

      let framesToConsume = Int(bytesToCopy/format.mBytesPerFrame)

      consumeNextBufferListPartial(framesToConsume: framesToConsume, format: format)

      bytesToGo -= bytesToCopy
      bytesCopied += bytesToCopy

    }

    let lengthInFrames = Int(count - bytesToGo / format.mBytesPerFrame)

    guard timestamp != nil else {
      fatalError("\(#fileID) \(#function) Expected to have a valid timestamp.")
    }

    return (lengthInFrames, timestamp!)

  }

  /// Determine how many frames of audio are buffered.
  ///
  /// Given the provided audio format, determines the frame count of all queued buffers.
  ///
  /// - Important: This function should only be used on the consumer thread,
  ///              not the producer thread.
  ///
  /// - Parameters:
  ///   - format: The format of the audio stored in the buffer
  ///   - contiguousTolerance: The number of samples of discrepancy to tolerate.
  /// - Returns: The number of frames in the given audio format that are in the buffer
  ///            and their associated timestamp or `nil` if no frames are available.
  func peek(format: AudioStreamBasicDescription,
            contiguousTolerance: UInt32 = UInt32.max) -> (Int, AudioTimeStamp)?
  {

    guard let (block, availableBytes) = tail() else { return nil }

    assert(Int(bitPattern: block) & 0xF == 0) /* Beware unaligned accesses */

    let boundBlock = block.load(as: ABLBlockHeader.self)

    let timestamp = boundBlock.timestamp

    let end = block + availableBytes

    var currentBlock = block

    var byteCount = UInt32()

    while true {

      var loadedBlock = currentBlock.load(as: ABLBlockHeader.self)
      let currentList = UnsafeMutableAudioBufferListPointer(&loadedBlock.bufferList)
      let currentListBytes = currentList.first?.mDataByteSize ?? 0

      byteCount += currentListBytes

      let nextBlock = currentBlock + Int(loadedBlock.totalLength)

      guard Int(bitPattern: nextBlock) < Int(bitPattern: end) else { break }

      let nextLoadedBlock = nextBlock.load(as: ABLBlockHeader.self)

      let delta = nextLoadedBlock.timestamp.mSampleTime
                - loadedBlock.timestamp.mSampleTime
                + Double(currentListBytes) / Double(format.mBytesPerFrame)

      guard contiguousTolerance == UInt32.max
              || UInt32(fabs(delta)) <= contiguousTolerance
      else
      {
        break
      }

      assert(Int(bitPattern: nextBlock) & 0xF == 0) /* Beware unaligned accesses */
      currentBlock = nextBlock

    }

    return (Int(byteCount), timestamp)

  }

  /// Determine how many much space there is in the buffer.
  ///
  /// Given the provided audio format, determines the number of frames of audio that
  /// can be buffered.
  ///
  /// - Important: This function should only be used on the producer thread,
  ///              not the consumer thread.
  /// - Parameter format: The format of the audio stored in the buffer.
  /// - Returns: The number of frames in the given audio format that can be stored in
  ///            the buffer
  func getAvailableSpace(format: AudioStreamBasicDescription) -> Int {

    // Look at buffer head; make sure there's space for the block metadata.
    guard let (block, availableBytes) = head() else { return 0 }

    assert(Int(bitPattern: block) & 0xF == 0) /* Beware unaligned accesses */

    // Now find out how much 16-byte aligned audio we can store in the space available.
    let numberOfBuffers = format.mFormatFlags & kAudioFormatFlagIsNonInterleaved != 0
                          ? format.mChannelsPerFrame
                          : 1

    let endOfBufferAddress = Int(bitPattern: block + availableBytes)
    var boundBlock = block.load(as: ABLBlockHeader.self)
    let blockList = UnsafeMutableAudioBufferListPointer(&boundBlock.bufferList)
    let blockListAddress = Int(bitPattern: blockList.unsafePointer)
    let offset = MemoryLayout<AudioBufferList>.size
               + (Int(numberOfBuffers) - 1) * MemoryLayout<AudioBuffer>.size

    let dataPointerAddress = align16Byte(blockListAddress + offset)

    guard dataPointerAddress < endOfBufferAddress else { return 0 }

    let availableAudioBytes = endOfBufferAddress - dataPointerAddress
    var availableAudioBytesPerBuffer = availableAudioBytes / Int(numberOfBuffers)
    availableAudioBytesPerBuffer -= availableAudioBytesPerBuffer % (16 - 1)

    guard availableAudioBytesPerBuffer > 0 else { return 0 }

    return availableAudioBytesPerBuffer / Int(format.mBytesPerFrame)

  }

}
