//  main.cpp

// A serial port utility for MacOS X

// For communicating with serial devices (e.g. microcontrollers)
// usually via USB serial.

//Includes
#include "SerialPort/SerialPort.hpp"
#include "TypeAbbreviations/TypeAbbreviations.hpp"
#include <iostream>

int main(int argc, const char * argv[]) {

    //* Open port, and connect to a device
    const char devicePathStr[] = "/dev/tty.SLAB_USBtoUART";
    const int baudRate = 115200;
    int sfd = openAndConfigureSerialPort(devicePathStr, baudRate);
    if (sfd < 0) {
        if (sfd == -1) {
            printf("Unable to connect to serial port.\n");
        }
        else { //sfd == -2
            printf("Error setting serial port attributes.\n");
        }
        return 0;
    }

    // * Read using readSerialData(char* bytes, size_t length)
    
    // * Write using writeSerialData(const char* bytes, size_t length)
    
    // * Remember to flush potentially buffered data when necessary
    
    // * Close serial port when done
    closeSerialPort();
    
    return 0;
}
