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
class ScriptRunner:     
    def __init__(self, ntp_server_ip: str, logger_ref: LoggerWrapper, is_root: bool) -> None:
        self.logger = logger_ref
        self.is_root = is_root
        self.ntp_server_ip = ntp_server_ip
        self.logger.info(f"is running via root? : {self.is_root}")
        self.determine_bash_alias()
        self.username = self.get_username()
        # self.hostname = self.get_hostname()
        self.hostname = self.get_hostname_alternate()
        self.logger.info(f"hostname: {self.hostname}, ntp server ip: { self.ntp_server_ip}")
        self.determine_user_pass()
    
    def get_hostname(self):
        import socket
        return socket.gethostname()

    def get_hostname_alternate(self) -> str: #if socket package does not exist
        output, error, ret_code = self.bash_command("hostname")
        if ret_code != 0:
            self.logger.error(f"get_hostname_alternate -> command failed!, error: {error}")
            sys.exit(1)
        else:
            self.logger.info(f"get_hostname_alternate -> command success!, hostname: {output}")
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

    def bash_alias_wrapper(self, cmd: str):
        output, errors, ret_code = self.bash_alias(cmd)
        self.logger.info(f"output: {output}, error: {errors}, return code: {ret_code}")
        if ret_code != 0:
            self.logger.error(f"command failed!")
            sys.exit(1)
        else:
            self.logger.info(f"command success!")

    def run_script(self, script: str):
        if self.check_if_exists(script):
            self.bash_alias_wrapper(f". {script}")
        else:
            self.logger.error(f"script not found! : {script}")
            sys.exit(1)
        
    def check_if_exists(self, path: str) -> bool:
        # create file if not exists under /etc/profile.d
        file_or_dir = Path(path)
        if file_or_dir.exists():
            return True
        else:
            return False        




def main():
    # Initialize parser
    parser = argparse.ArgumentParser()
    parser.add_argument("--ntp", help="ntp server ip") # TODO
    parser.add_argument("--runViaRoot", help="is running user root? -> boolean")
    parser.add_argument("--script", help="bash script to run")
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

    ntp_server_ip=None
    run_via_root=None
    script_to_run=None

    if args.ntp:
        main_logger.info(f"host: {str(args.ntp)}")
        ntp_server_ip = str(args.ntp)

    if args.script:
        main_logger.info(f"host: {str(args.script)}")
        script_to_run = str(args.script)

    if args.runViaRoot:
        main_logger.info(f"run_via_root ?: {bool(int(args.runViaRoot))}")
        run_via_root = bool(int(args.runViaRoot))

    if script_to_run is None or ntp_server_ip is None or run_via_root is None:
        main_logger.error(f"host and port parameters are required!")
        main_logger.info(f"usage example: 'python3 script_runner.py --runViaRoot <running_user> --script <script> --ntp <ntp_server_ip>'")
        sys.exit(1)


    script_runner = ScriptRunner(
        ntp_server_ip=ntp_server_ip,
        logger_ref=main_logger,
        is_root=run_via_root
    )

    script_runner.run_script(
        script=script_to_run
    )


if __name__ == "__main__":
    main()