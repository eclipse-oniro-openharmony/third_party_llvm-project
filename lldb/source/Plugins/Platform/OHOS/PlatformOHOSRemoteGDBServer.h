//===-- PlatformOHOSRemoteGDBServer.h ------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef liblldb_PlatformOHOSRemoteGDBServer_h_
#define liblldb_PlatformOHOSRemoteGDBServer_h_

#include <map>
#include <utility>

#include "Plugins/Platform/gdb-server/PlatformRemoteGDBServer.h"

#include "llvm/ADT/Optional.h"

#include "HdcClient.h"

namespace lldb_private {
namespace platform_ohos {

class PlatformOHOSRemoteGDBServer
    : public platform_gdb_server::PlatformRemoteGDBServer {
public:
  PlatformOHOSRemoteGDBServer();

  ~PlatformOHOSRemoteGDBServer() override;

  Status ConnectRemote(Args &args) override;

  Status DisconnectRemote() override;

  lldb::ProcessSP ConnectProcess(llvm::StringRef connect_url,
                                 llvm::StringRef plugin_name,
                                 lldb_private::Debugger &debugger,
                                 lldb_private::Target *target,
                                 lldb_private::Status &error) override;

protected:
  std::string m_device_id;
  std::map<lldb::pid_t, std::pair<uint16_t, uint16_t>> m_port_forwards;
  std::map<lldb::pid_t, std::pair<uint16_t, std::string>> m_remote_socket_name;
  llvm::Optional<HdcClient::UnixSocketNamespace> m_socket_namespace;

  bool LaunchGDBServer(lldb::pid_t &pid, std::string &connect_url) override;

  bool KillSpawnedProcess(lldb::pid_t pid) override;

  void DeleteForwardPort(lldb::pid_t pid);

  Status MakeConnectURL(const lldb::pid_t pid, const uint16_t remote_port,
                        llvm::StringRef remote_socket_name,
                        std::string &connect_url);

private:
  PlatformOHOSRemoteGDBServer(const PlatformOHOSRemoteGDBServer &other) = delete;
  PlatformOHOSRemoteGDBServer& operator=(const PlatformOHOSRemoteGDBServer &other) = delete;
};

} // namespace platform_ohos
} // namespace lldb_private

#endif // liblldb_PlatformOHOSRemoteGDBServer_h_
