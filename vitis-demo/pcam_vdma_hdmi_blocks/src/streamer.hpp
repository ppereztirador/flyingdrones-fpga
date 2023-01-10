#ifndef STREAMER_HPP
#define STREAMER_HPP

#include <stdio.h>
#include <string>
#include <vector>

#define NAL_FRAME_HEADER_SEPARATION 48
#define NAL_STREAM_HEADER_MULTIPLY 2

// Header that will be used at the start of the stream
const char streamHeader[11] = {0x00, 0x00, 0x00, 0x01, 0x67, 0x42,
                               0x00, 0x0a, 0xf8, 0x41, 0xa2};
// Header that will be used periodically to signal resolutions
const char frameHeader[8] = {0x00, 0x00, 0x00, 0x01, 0x68, 0xce, 0x38, 0x80};
// Header that will be used at the start of each NAL
const char nalHeader[5] = {0x00, 0x00, 0x00, 0x01, 0x60};

/**
 * @brief Use to output encoder frame to a file using the H264 NAL format
 */
class Streamer {
public:
  /**
   * @brief Inits the streamer with required destination
   * @param destination File to use as output for the streamer, stdout can be
   * suplied as output
   */
  Streamer(std::string destination);
  /**
   * @brief Finishes the streaming
   */
  ~Streamer();
  /**
   * @brief Send data to the supplied output
   * @param data Pointer to the data to send
   * @param dataSize Size in bytes of the data pointer
   */
  void send(char *data, size_t dataSize);
  /**
   * @brief Send data to the supplied output
   * @param data Vector containing
   */
  void send(std::vector<char> data);

private:
  /**
   * @brief Adds the Nal header to a vector
   * @param destination Vector to push the nal into
   */
  static void addNALHeader(std::vector<char> &destination);

  /**
   * @brief Scans an array checking for emulation prevention bytes required
   * @param destination Vector to push the nal into
   */
  static void addEmulationPreventionBytes(std::vector<char> &destination,
                                          char *input, size_t inputSize);
  /**
   * @brief Put an array into the output configured
   * @param data Pointer to the data to send
   * @param dataSize Size in bytes of the data pointer
   */
  void putIntoFile(char *data, size_t dataSize);

  // Mode in which the streamer can work
  enum Mode { Stdout = 0, File = 1, Serial = 2 };
  // File to output the stream
  FILE *m_output;
  // Intermediate buffer to emulate the prevention bytes
  std::vector<char> m_intermediate;
  // Mode in which the streamer is working
  Mode m_mode;
  // Counts the nals out
  unsigned int nal_counter;
};

#endif /* STREAMER_HPP */
