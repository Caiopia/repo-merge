//
//  BSG_KSMachHeaders.h
//  Bugsnag
//
//  Created by Robin Macharg on 28/04/2020.
//  Copyright © 2020 Bugsnag. All rights reserved.
//

#ifndef BSG_KSMachHeaders_h
#define BSG_KSMachHeaders_h

/**
 * An encapsulation of the Mach header - either 64 or 32 bit, along with some additional information required for
 * detailing a crash report's binary images.
 */
typedef struct {
    const struct mach_header *mh;      /* The mach_header - 32 or 64 bit */
    uint64_t imageVmAddr;
    uint64_t imageSize;
    uint8_t *uuid;
    const char* name;
    cpu_type_t cputype;          /* cpu specifier */
    cpu_subtype_t cpusubtype;    /* machine specifier */
} BSG_Mach_Binary_Image_Info;

/**
 * Returns a C array of structs describing the loaded Mach binaries
 *
 * @param count A reference to the length of the array
 *
 * @returns A reference to an array of BSG_Mach_Binary_Image_Info structs containing info
 *          about a loaded Mach binary.
 */
BSG_Mach_Binary_Image_Info* bsg_mach_header_array(size_t *count);

/**
 * Called when a binary image is loaded.
 */
void bsg_mach_binary_image_added(const struct mach_header *mh, intptr_t slide);

/**
 * Called when a binary image is unloaded.
 */
void bsg_mach_binary_image_removed(const struct mach_header *mh, intptr_t slide);

/**
 * Create an empty, mutable NSArray to hold Mach header info
 */
void bsg_initialise_mach_binary_headers(void);

#endif /* BSG_KSMachHeaders_h */
