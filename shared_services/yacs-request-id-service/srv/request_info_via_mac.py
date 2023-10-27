import os
import argparse
import sys
import subprocess
from pathlib import Path
from typing import Tuple

class LoggerWrapper:
    def __init__(self, name: str, use_logging: bool = False) -> None:
        self.name = name
        self.logger = None
        if use_logging:
            import logging
            logging.basicConfig(level=logging.INFO, stream=sys.stderr)
            self.logger = logging.getLogger("ScriptRunner")

    def info(self, log: str):
        if self.logger:
            self.logger.info(f"{log}")
        else:
            print(f"[{self.name}] [INFO]: {log}")

    def error(self, log: str):
        if self.logger:
            self.logger.error(f"{log}")
        else:
            print(f"[{self.name}] [ERROR]: {log}")

    def warn(self, log: str):
        if self.logger:
            self.logger.warn(f"{log}")
        else:
            print(f"[{self.name}] [WARN]: {log}")

    def debug(self, log: str):
        if self.logger:
            self.logger.debug(f"{log}")
        else:
            print(f"[{self.name}] [DEBUG]: {log}")

class ApiRequestHelper:     
    def __init__(self, host: str, port: int, logger_ref: LoggerWrapper, is_root: bool) -> None:
        self.host = host      
        self.port = port
        self.logger = logger_ref
        self.is_root = is_root
        self.logger.info(f"is running via root? : {self.is_root}")
        self.determine_bash_alias()
        self.username = self.get_username()
        self.hostname = self.get_hostname()
        self.ip = self.get_ip()
        self.mac_address = self.get_mac_address()
        self.logger.info(f"hostname: {self.hostname}, ip: {self.ip} , mac: {self.mac_address}")
        self.determine_user_pass()
    
    def get_hostname(self) -> str: #if socket package does not exist
        output, error, ret_code = self.bash_command("hostname")
        if ret_code != 0:
            self.logger.error(f"get_hostname -> command failed!, error: {error}")
            sys.exit(1)
        else:
            self.logger.info(f"get_hostname -> command success!, hostname: {output}")
            return output.decode('utf-8').strip()
    
    def get_username(self):
        return os.environ.get('USER', os.environ.get('USERNAME'))        

    def determine_user_pass(self):
        if self.hostname == "firefly":
            self.user = "svrn"
            self.password = "1234"
        elif self.hostname == "fio":
            self.user = "fio"
            self.password = "fio"
        elif "portenta" in self.hostname:
            self.user = "fio"
            self.password = "fio"
        else:
            self.logger.error(f"unexpected hostname : {self.hostname}")
            sys.exit(1)

    def get_user_id(self) -> str:
        data = self.bash_alias_wrapper(f"wget -qO- {self.host}:{self.port}/get_id/{self.mac_address}")
        self.logger.info(f"received user id -> {data}")
        return data

    def run_script(self, script: str):
        if self.check_if_exists(script):
            self.bash_alias_wrapper(f". {script}")
        else:
            self.logger.error(f"script not found! : {script}")
            sys.exit(1)

    def get_ip(self):
        get_ip_script_local = "get_ip.sh"
        get_ip_script_service_loc = "/var/get_ip.sh"

        def do_after_found(script: str):
            output, error, ret_code = self.bash_command(f". {script}")
            if ret_code != 0:
                self.logger.error(f"get_ip -> command failed!, error: {error}")
                sys.exit(1)
            else:
                self.logger.info(f"get_ip -> command success!, ip: {output}")
                return output.decode('utf-8').strip()

        if self.check_if_exists(get_ip_script_local):
            return do_after_found(get_ip_script_local)
        elif self.check_if_exists(get_ip_script_service_loc):
            return do_after_found(get_ip_script_service_loc)
        else:
            self.logger.error(f"get_ip -> script not found! : {get_ip_script_local}")
            sys.exit(1)    

    def get_environment_var(self, var: str):
        return os.getenv(var)
    
    def bash_command(self, cmd) -> Tuple[str,str,int]:
        sp = subprocess.Popen(['/bin/bash', '-c', cmd], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, errors = sp.communicate()
        return (output, errors, sp.returncode)

    def bash_command_with_sudo(self, cmd) -> Tuple[str,str,int]:
        sudo_pipe = subprocess.Popen(['echo',self.password], stdout=subprocess.PIPE)
        sp = subprocess.Popen(['sudo','-S', '/bin/bash', '-c', cmd], stdin=sudo_pipe.stdout, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        output, errors = sp.communicate()
        return (output, errors, sp.returncode)

    def determine_bash_alias(self):
        self.bash_alias = self.bash_command
        if not self.is_root:
            self.bash_alias = self.bash_command_with_sudo

        self.logger.info(f"bash_alias -> {self.bash_alias}")

    def get_mac_address(self) -> str:
        mac_address = str(-1)
        bashReturn_mac, errors, ret_code = self.bash_command(
            "cat /sys/class/net/$(ip route show default | awk '/default/ {print $5}')/address"
        )        
        self.logger.info(f"get_mac_address -> output: {bashReturn_mac}, error: {errors}, return code: {ret_code}")    
        if (len(bashReturn_mac) > 0):
            mac_address = bashReturn_mac.decode('utf-8').strip()
        return mac_address

    def change_file_contents(self, file_path: str, match_case: str, replacement: str):
        # setting env variable via /etc/environment did not work, putting a script under /etc/profile.d/ works!
        self.logger.info(f"change_file_contents -> file: {file_path}, match_case: {match_case}, replacement: {replacement}")

        is_string_exists, errors, ret_code = self.bash_alias(
            f"grep {match_case} {file_path}" 
        )
        if len(is_string_exists) > 0:
            # self.bash_alias(
            #     f"sed -i 's/{match_case}=.*/{match_case}={replacement}/' {file_path}"
            # )
            self.bash_alias_wrapper(f"sed -i 's/{match_case}=.*/{match_case}={replacement}/' {file_path}")
        else:            
            # self.bash_alias(
            #     # f"echo '{match_case}={replacement}' | sudo tee --append '{file_path}'"
            #     f"echo 'export {match_case}={replacement}' | sudo tee --append '{file_path}'"
            # )
            self.bash_alias_wrapper(f"echo 'export {match_case}={replacement}' | sudo tee --append '{file_path}'")

    def bash_alias_wrapper(self, cmd: str):
        output, errors, ret_code = self.bash_alias(cmd)
        self.logger.info(f"output: {output}, error: {errors}, return code: {ret_code}")
        if ret_code != 0:
            self.logger.error(f"command failed!")
            sys.exit(1)
        else:
            self.logger.info(f"command success!")
            return output.decode('utf-8').strip()
        
    def recreate_file_via_copy_edit_move(self, source_file: str, match_case: str, replacement: str, temp_dir: str, source_dir: str):
        # service fails when trying to change file in-place -> "sed: couldn't open temporary file /etc/profile.d/sed1KICpo: Read-only file system"
        #copy file to tmp
        # temp_dir = "/tmp"
        # source_dir = "/etc/profile.d"
        # source_file = "custom_env_vars.sh"
        source_file_path = source_dir + source_file
        self.bash_alias_wrapper(f"cp {source_file_path} {temp_dir}")

        # change file contents
        temp_file_path = str(temp_dir + source_file)
        self.change_file_contents(temp_file_path, match_case, replacement)
        # move old file
        self.bash_alias_wrapper(f"mv -f {source_file_path} {str(source_file_path + '.bak')}")
        # move new file to /etc/profile.d
        self.bash_alias_wrapper(f"mv {temp_file_path} {source_dir}")

    def check_if_exists(self, path: str) -> bool:
        # create file if not exists under /etc/profile.d
        file_or_dir = Path(path)
        if file_or_dir.exists():
            return True
        else:
            return False
        

    def configure_env_var(self, env_var: str, value: str):
        # if file does not exist, create and fill it
        # otherwise, match & change env var line from that file
        # env_var_file = "/etc/profile.d/custom_env_vars.sh"
        env_var_file = "/var/custom_env_vars_source"
        if self.check_if_exists(env_var_file):
            self.logger.info(f"{env_var_file} found, editing for '{value}'")
            self.change_file_contents(
                file_path=env_var_file,
                match_case=env_var,
                replacement=value
            )
            # self.recreate_file_via_copy_edit_move(
            #     source_file="custom_env_vars.sh",
            #     match_case=env_var,
            #     replacement=value,
            #     temp_dir="/tmp/",
            #     source_dir="/etc/profile.d/"
            # )
        else:
            self.logger.info(f"{env_var_file} not found, creating and filling with '{env_var}={value}'")

            self.bash_alias(
                f"dd of={env_var_file} << EOF\n" \
                f"export {env_var}={value}\n" \
                "EOF"
            )


def main():
    # Initialize parser
    parser = argparse.ArgumentParser()
    parser.add_argument("--host", help="host ip")
    parser.add_argument("--port", help="host access port")
    parser.add_argument("--runViaRoot", help="is running user root? -> boolean")
    parser.add_argument("--useLoggingLib", help="0: use print, 1: use logging lib")
    args, unknown = parser.parse_known_args()

    use_logging_lib=False
    if args.useLoggingLib:
        use_logging_lib = bool(int(args.useLoggingLib))
        print(f"use logging lib? : {use_logging_lib}")

    # set up logger
    main_logger = LoggerWrapper("ScriptRunner", use_logging_lib)
    if unknown:
        main_logger.info(f"unknwon args: {unknown}")

    host=None
    port=None
    run_via_root=None

    if args.host:
        main_logger.info(f"host: {str(args.host)}")
        host = str(args.host)
    
    if args.port:
        main_logger.info(f"port: {int(args.port)}")
        port = int(args.port)

    if args.runViaRoot:
        main_logger.info(f"run_via_root ?: {bool(int(args.runViaRoot))}")
        run_via_root = bool(int(args.runViaRoot))

    if host is None or port is None or run_via_root is None:
        main_logger.error(f"host and port parameters are required!")
        main_logger.info(f"usage example: 'python3 request_info_via_mac.py --running_as <running_user> --host <server_ip> --port <server_port>'")
        sys.exit(1)


    request_helper = ApiRequestHelper(
        host="2.12.100.112",
        port=8888,
        logger_ref=main_logger,
        is_root=run_via_root
    )

    user_id = request_helper.get_user_id()

    # create||edit /etc/profile.d/<script>.sh
    request_helper.configure_env_var(
        env_var="USER_ID",
        value=str(user_id)
    )


if __name__ == "__main__":
    main()