%define BOOT1_ADDR 						0x7C00						; Address of the first booted sector
%define BOOT2_ADDR 						0x1000						; Address of the second stage
%define MBR_ADDR						0x7A00						; Address of the relocated MBR

%define STACK_ADDR						0xF000						; Address of the stack

%define PTABLE_OFFSET					0x01BE						; Address of the partition table
%define PENTRY_SIZE						0x10						; Size of each partition entry
%define PENTRY_BOOT_FLAG				1 << 7						; The bit to check if the partition is bootable
%define PENTRY_LBA_OFFSET				0x08

%define MAX_DAP_SECTORS					72

%define EOC								0x0FFFFFF8					; End of cluster marker

%define BPB_OEM_LABEL					0x03
%define BPB_BYTES_PER_SECTOR 	    	0x0B
%define BPB_SECTORS_PER_CLUSTER   		0x0D
%define BPB_RESERVED_SECTORS	    	0x0E
%define BPB_NUMBER_OF_FATS 	    		0x10
%define BPB_ROOT_DIR_ENTRIES	   		0x11
%define BPB_LOGICAL_SECTORS 	   		0x13
%define BPB_MEDIA_DESCRIPTOR     		0x15
%define BPB_SECTORS_PER_FAT	    		0x16
%define BPB_SECTORS_TER_TRACK			0x18
%define BPB_NUMBER_OF_HEADS				0x1A
%define BPB_HIDDEN_SECTORS 				0x1C
%define BPB_LARGE_SECTOR_COUNT			0x20
%define BPB_LOGICAL_SECTORS_PER_FAT		0x24
%define BPB_MIRRORING_FLAGS 			0x28
%define BPB_VERSION  					0x2A
%define BPB_ROOT_DIR_CLUSTER 			0x2C
%define BPB_FS_INFO_SECTOR				0x30
%define BPB_BACKUP_SECTOR				0x32
%define BPB_BOOT_FILE_NAME 				0x34
%define BPB_DRIVE 						0x40
%define BPB_BPB_FLAGS 					0x41
%define BPB_EXT_BOOT_SIGN				0x42
%define BPB_SERIAL 						0x43
%define BPB_VOLUME_ID					0x43
%define BPB_VOLUME_LABEL				0x47
%define BPB_FILESYSTEM_TYPE 			0x52
