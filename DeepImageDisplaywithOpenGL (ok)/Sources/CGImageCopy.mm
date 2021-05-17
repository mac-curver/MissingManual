/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Utility methods for "fast-string" memory copy.
 */

#pragma mark -
#pragma mark Private - Headers

#import <iostream>

#import "CGImageCopy.h"

#pragma mark -
#pragma mark Public - Utilities

// "Fast string" memory copy better suited for image copy
uint8_t* CG::memcpy(const size_t& rSize,
                    const uint8_t* pSrc,
                    uint8_t* pDst)
{
    asm volatile("mov %[d], %%rdi\n"
                 "mov %[s], %%rsi\n"
                 "mov %[c], %%rcx\n"
                 "rep/movsb\n"
                 :
                 : [d] "r" (pDst),
                 [s] "r" (pSrc),
                 [c] "r" (rSize)
                 : "%rdi", "%rsi", "%rcx", "memory");
    
    return pDst;
} // Mem::Copy

// "Fast string" memory copy better suited for image copy
void* CG::memcpy(const size_t& rSize,
                 const void* pIn,
                 void* pOut)
{
    const uint8_t* pSrc = static_cast<const uint8_t *>(pIn);
    uint8_t*       pDst = static_cast<uint8_t *>(pOut);
    
    return CG::memcpy(rSize, pSrc, pDst);
} // memcpy

// I/O surface errors that could potentially occur when
// copying from a source to destination surface
#define kMacroIOReturnCpyErrSrcRef   iokit_common_err(0x3b1) // Null source i/o reference
#define kMacroIOReturnCpyErrDstRef   iokit_common_err(0x3b2) // Null destination i/o reference
#define kMacroIOReturnCpyErrHeight   iokit_common_err(0x3b3) // Invalid height
#define kMacroIOReturnCpyErrRowBytes iokit_common_err(0x3b4) // Invalid row bytes
#define kMacroIOReturnCpyErrSize     iokit_common_err(0x3b5) // Plane size is zero
#define kMacroIOReturnCpyErrSrcPtr   iokit_common_err(0x3b6) // Null pointer for source surface base address
#define kMacroIOReturnCpyErrDstPtr   iokit_common_err(0x3b7) // Null pointer for destination surface base address

IOReturn CG::kIOReturnCpySuccess     = kIOReturnSuccess;
IOReturn CG::kIOReturnCpyErrSrcRef   = kMacroIOReturnCpyErrSrcRef;
IOReturn CG::kIOReturnCpyErrDstRef   = kMacroIOReturnCpyErrDstRef;
IOReturn CG::kIOReturnCpyErrHeight   = kMacroIOReturnCpyErrHeight;
IOReturn CG::kIOReturnCpyErrRowBytes = kMacroIOReturnCpyErrRowBytes;
IOReturn CG::kIOReturnCpyErrSize     = kMacroIOReturnCpyErrSize;
IOReturn CG::kIOReturnCpyErrSrcPtr   = kMacroIOReturnCpyErrSrcPtr;
IOReturn CG::kIOReturnCpyErrDstPtr   = kMacroIOReturnCpyErrDstPtr;

// Copy from a source to destination i/o surface at a plane given by a source
// index to a destination i/o surface at a plane  given by a destination index
IOSurfaceRef CG::s2dcpy(const size_t& nSrcIdx,
                        const IOSurfaceRef pSrc,
                        const size_t& nDstIdx,
                        IOSurfaceRef pDst,
                        IOReturn& nResult)
{
    nResult = (pSrc != nullptr) ? CG::kIOReturnCpySuccess : CG::kIOReturnCpyErrSrcRef;
    
    if(nResult == CG::kIOReturnCpySuccess)
    {
        nResult = (pDst != nullptr) ? CG::kIOReturnCpySuccess : CG::kIOReturnCpyErrDstRef;
        
        if(nResult == CG::kIOReturnCpySuccess)
        {
            uint32_t nSrcSeed = 0;
            
            nResult = IOSurfaceLock(pSrc, kIOSurfaceLockReadOnly, &nSrcSeed);
            
            if(nResult == CG::kIOReturnCpySuccess)
            {
                uint32_t nDstSeed = 0;
                
                nResult = IOSurfaceLock(pDst, 0, &nDstSeed);
                
                if(nResult == CG::kIOReturnCpySuccess)
                {
                    const size_t nSrcHeight = IOSurfaceGetHeightOfPlane(pSrc, nSrcIdx);
                    const size_t nDstHeight = IOSurfaceGetHeightOfPlane(pDst, nDstIdx);
                    
                    nResult = (nSrcHeight == nDstHeight) ? CG::kIOReturnCpySuccess : CG::kIOReturnCpyErrHeight;
                    
                    if(nResult == CG::kIOReturnCpySuccess)
                    {
                        const size_t nSrcRowBytes = IOSurfaceGetBytesPerRowOfPlane(pSrc, nSrcIdx);
                        const size_t nDstRowBytes = IOSurfaceGetBytesPerRowOfPlane(pDst, nDstIdx);
                        
                        nResult = (nSrcRowBytes == nDstRowBytes) ? CG::kIOReturnCpySuccess : CG::kIOReturnCpyErrRowBytes;
                        
                        if(nResult == CG::kIOReturnCpySuccess)
                        {
                            const size_t nDstSize = nDstHeight * nDstRowBytes;
                            
                            nResult = (nDstSize > 0) ? CG::kIOReturnCpySuccess : CG::kIOReturnCpyErrSize;
                            
                            if(nResult == CG::kIOReturnCpySuccess)
                            {
                                const void* pSrcAddr = IOSurfaceGetBaseAddressOfPlane(pSrc, nSrcIdx);
                                
                                nResult = (pSrcAddr != nullptr) ? CG::kIOReturnCpySuccess : CG::kIOReturnCpyErrSrcPtr;
                                
                                if(nResult == CG::kIOReturnCpySuccess)
                                {
                                    void* pDstAddr = IOSurfaceGetBaseAddressOfPlane(pDst, nDstIdx);
                                    
                                    nResult = (pDstAddr != nullptr) ? CG::kIOReturnCpySuccess : CG::kIOReturnCpyErrDstPtr;
                                    
                                    if(nResult == CG::kIOReturnCpySuccess)
                                    {
                                        CG::memcpy(nDstSize, pSrcAddr, pDstAddr);
                                    } // if
                                } // if
                            } // if
                        } // if
                    } // if
                    
                    IOSurfaceUnlock(pDst, 0, &nDstSeed);
                } // if
                
                IOSurfaceUnlock(pSrc, 0, &nSrcSeed);
            } // if
        } // if
    } // if
    
    return pDst;
} // s2dcpy

// Copy from a source to destination i/o surface at plane 0
IOSurfaceRef CG::s2dcpy(const IOSurfaceRef pSrc,
                        IOSurfaceRef pDst,
                        IOReturn& nResult)
{
    return CG::s2dcpy(0, pSrc, 0, pDst, nResult);
} // s2dcpy
