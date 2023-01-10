#include <iostream>
#include "xil_printf.h"

#ifdef _WIN32
#include <fcntl.h>
#include <io.h>
#endif

#include "streamer.hpp"

Streamer::Streamer(std::string destination) {
  m_output = nullptr;
  m_intermediate.reserve(8000);
  if (destination.find("stdout") == 0) {
    m_mode = Stdout;
#ifdef _WIN32
    setmode(_fileno(stdout), _O_BINARY);
#endif
  } else if (destination.find("serial") == 0) {
	  m_mode = Serial;
  }
  else {
    m_mode = File;
    m_output = fopen(destination.c_str(), "w");
    if (m_output == NULL) {
      xil_printf("Error abriendo el fichero de salida del streamer\n\r");
    }
  }
}

Streamer::~Streamer() {
  if (m_mode == File && m_output != nullptr)
    fclose(m_output);
}

void Streamer::send(char *data, size_t dataSize) {
  if (nal_counter % NAL_FRAME_HEADER_SEPARATION * NAL_STREAM_HEADER_MULTIPLY ==
      0) {
    putIntoFile((char *)streamHeader, sizeof(streamHeader));
  }
  if (nal_counter % NAL_FRAME_HEADER_SEPARATION == 0) {
    putIntoFile((char *)frameHeader, sizeof(frameHeader));
  }
  m_intermediate.reserve(dataSize * 2);
  m_intermediate.resize(0);
  Streamer::addNALHeader(m_intermediate);
  Streamer::addEmulationPreventionBytes(m_intermediate, data, dataSize);
  putIntoFile(m_intermediate.data(), m_intermediate.size());
  nal_counter++;
}

void Streamer::send(std::vector<char> data) { send(data.data(), data.size()); }

void Streamer::addNALHeader(std::vector<char> &destination) {
  destination.insert(destination.end(), nalHeader,
                     nalHeader + sizeof(nalHeader));
}

void Streamer::addEmulationPreventionBytes(std::vector<char> &destination,
                                           char *input, size_t inputSize) {
  int i, j;
  for (i = 0; i < inputSize - 2; i++) {
    if (input[i] == 0 && input[i + 1] == 0 &&
        (input[i + 2] == 0 || input[i + 2] == 1 || input[i + 2] == 2 ||
         input[i + 2] == 3)) {
      destination.push_back(0);
      destination.push_back(0);
      destination.push_back(0x03);
      i += 1;
    } else {
      destination.push_back(input[i]);
    }
  }
  for (j=i; j < inputSize; j++) {
    destination.push_back(input[j]);
  }
}

void Streamer::putIntoFile(char *data, size_t dataSize) {
  size_t written;
  int i;
  if (m_mode == File) {
    written = fwrite(data, sizeof(char), dataSize, m_output);
  } else if(m_mode == Serial) {
	  xil_printf("%d", dataSize);
	  for (i=0; i<dataSize; i++) {
		  xil_printf("%c", data[i]);
	  }
  }
  else {
    written = fwrite(data, sizeof(char), dataSize, stdout);
  }
  if (written != dataSize) {
    xil_printf("Error escribiendo en el fichero");
  }
}
