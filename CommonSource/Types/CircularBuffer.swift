//
//  CircularBuffer.swift
//  ChordFinder
//
//  Created by Jason Cardwell on 12/13/20.
//  Copyright © 2020 Moondeer Studios. All rights reserved.
//
import Foundation
import Darwin
import Accelerate
import AudioToolbox


struct CircularBuffer {

  /// Base address as returned by `vm_allocate`.
  let bufferAddress: vm_address_t

  /// Base address of the contiguous storage.
  private var buffer: UnsafeMutableRawPointer

  /// The capacity of the buffer.
  let capacity: Int

  /// Index of the buffer's tail.
  private var tailIndex: Int = 0

  /// Index of the buffer's head.
  private var headIndex: Int = 0

  /// The count of unread samples.
  private var fillCount: Int = 0

// MARK: Initializing

  /// Initializing the buffer.
  ///
  /// - Parameter proposedLength: Desired buffer capacity. Because of the way the
  ///                             memory mirroring technique works, the true buffer
  ///                             length will be multiples of the device page size
  ///                             (e.g. 4096 bytes)
  init(length proposedLength: Int) {

    func trunc_page(_ x: Int) -> Int { ((x) & (~(Int(vm_page_size) - 1))) }
    func round_page(_ x: Int) -> Int { trunc_page((x) + (Int(vm_page_size) - 1)) }

    let length = vm_size_t(round_page(proposedLength)) // We need whole page sizes

    var retries = 3

    // Temporarily allocate twice the length, so we have the contiguous address space
    // to support a second instance of the buffer directly after.
    var bufferAddress = vm_address_t()

    repeat {

      var result = vm_allocate(mach_task_self_,
                               &bufferAddress,
                               length * 2,
                               VM_FLAGS_ANYWHERE)

      guard result == ERR_SUCCESS else {
        retries -= 1
        if retries == 0 {
          fatalError("\(#fileID) \(#function) Buffer allocation failed.")
        } else {
          continue
        }
      }

      // Now replace the second half of the allocation with a virtual copy of the first
      // half and deallocate the second half.
      result = vm_deallocate(mach_task_self_, bufferAddress + length, length)

      guard result  == ERR_SUCCESS else {
        retries -= 1
        if retries == 0 {
          fatalError("\(#fileID) \(#function) Buffer allocation failed.")
        } else {
          vm_deallocate(mach_task_self_, bufferAddress, length)
          continue
        }
      }

      // Re-map the buffer to the address space immediately after the buffer
      var virtualAddress = bufferAddress + length
      var cur_prot = vm_prot_t()
      var max_prot = vm_prot_t()
      result = vm_remap(mach_task_self_,
                        &virtualAddress,
                        length,
                        0,
                        0,
                        mach_task_self_,
                        bufferAddress,
                        0,
                        &cur_prot,
                        &max_prot,
                        VM_INHERIT_DEFAULT)

      guard result == ERR_SUCCESS else {
        retries -= 1
        if retries == 0 {
          fatalError("\(#fileID) \(#function) Buffer allocation failed.")
        } else {
          // If this remap failed, we hit a race condition, so deallocate and try again
          vm_deallocate(mach_task_self_, bufferAddress, length)
          continue
        }
      }

      // If the memory is not contiguous, clean up both allocated buffers and try again
      guard virtualAddress == bufferAddress + length else {
        retries -= 1
        if retries == 0 {
          fatalError("\(#fileID) \(#function) Couldn't map buffer memory to end.")
        } else {
          // If this remap failed, we hit a race condition, so deallocate and try again
          vm_deallocate(mach_task_self_, virtualAddress, length)
          vm_deallocate(mach_task_self_, bufferAddress, length)
          continue
        }
      }

      break

    } while true

    guard let buffer = UnsafeMutableRawPointer(bitPattern: bufferAddress) else {
      fatalError("""
                  \(#fileID) \(#function) \
                  Failed to create pointer to `bufferAddress`.
                  """)
    }

    self.bufferAddress = bufferAddress
    self.buffer = buffer
    self.capacity = Int(length)

  }

  /// Releases buffer resources.
  func cleanup() {

    // Deallocate the virtual memory.
    vm_deallocate(mach_task_self_, bufferAddress, vm_size_t(capacity))

  }

  /// Resets buffer to original, empty state.
  mutating func clear() {

    // Just return if the buffer is already empty.
    guard fillCount > 0 else { return }

    // Consume all the bytes in the buffer.
    consume(amount: fillCount)

  }

// MARK: Reading (consuming)

  /// This gives you a pointer to the end of the buffer, ready
  /// for reading, and the number of available bytes to read.
  ///
  /// - Returns: A tuple with a pointer to the address to be read
  ///            and the number of samples available to read.
  func tail() -> (UnsafeRawPointer, Int)? {

    // Return `nil` if there are no bytes to be read.
    guard fillCount > 0 else { return nil }

    // Return the address of the tail byte with available byte count.
    return (UnsafeRawPointer(buffer + tailIndex), fillCount)

  }

  /// Consume bytes in buffer to free them for writing again.
  ///
  /// - Parameter amount: The number of bytes to consume.
  mutating func consume(amount: Int) {

    // Limit the consumption to bytes filled.
    let amount = min(fillCount, amount)

    // Advance the tail index in a circular fashion.
    tailIndex = (tailIndex + amount) % capacity

    // Subtract the consumed bytes from the fill count.
    fillCount -= amount

  }

  /// This gives you a pointer to the front of the buffer, ready
  /// for writing, and the number of available bytes to write.
  ///
  /// - Returns: A tuple with a pointer to the address for writing and
  ///            the number of bytes available for writing.
  func head() -> (UnsafeMutableRawPointer, Int)? {

    // Calculate the number of bytes available for writing.
    let availableBytes = capacity - fillCount

    // Return `nil` if there is no free space in the buffer.
    guard availableBytes > 0 else { return nil }

    // Return the address of the head byte with available byte count.
    return ((buffer + headIndex), availableBytes)

  }

// MARK: Writing (producing)

  /// This marks the given section of the buffer ready for reading.
  ///
  /// - Parameter amount: Number of bytes to produce
  mutating func produce(amount: Int) {

    // Advance the head index in a circular fashion.
    headIndex = (headIndex + amount) % capacity

    // Update buffer's the fill count.
    fillCount += amount

    assert(fillCount <= capacity,
           "\(#fileID) \(#function) amount exceeded capacity.")

  }


  /// This copies the given bytes to the buffer, and marks them ready for writing.
  ///
  /// - Parameters:
  ///   - source: Source buffer
  ///   - count: Number of bytes in source buffer
  /// - Returns: `true` if bytes copied, `false` if there was insufficient space
  mutating func produceBytes(source: UnsafeRawPointer, count: Int) -> Bool {

    // Get a pointer to the head byte with enough space for `count` bytes
    // return `false`.
    guard let (headPointer, space) = head(), space >= count else { return false }

    // Copy the bytes into the buffer.
    memcpy(headPointer, source, count)

    // Mark the bytes as produced.
    produce(amount: count)

    // Return `true` for having copied the bytes successfully.
    return true

  }

}
