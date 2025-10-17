import os, traceback, subprocess

base_dir = os.path.dirname(os.path.abspath(__file__))
input_path = os.path.join(base_dir, "input")
output_path = os.path.join(base_dir, "output")

def run_decompiler(file_path):
    subprocess.run([
        "luajit-decompiler-v2.exe",
        file_path
    ], capture_output=True)

def write_main_file(input_file):
    input_file = input_file.replace("director:init(main.params)", "require(\"mods.mod_main\"):init(director)")

    with open("main.lua", "w", encoding="utf-8") as f:
        f.write(input_file)

def main():
    run_decompiler("main.lua")

    main_path = os.path.join("output", "main.lua")

    try:
        with open(main_path, "r", encoding="utf-8") as f:
            input_file = f.read()

            write_main_file(input_file)
    except Exception as e:
        traceback.print_exc()

if __name__ == "__main__":
    main()

    input("程序运行完毕, 按回车键退出> ")