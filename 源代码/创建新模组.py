import traceback
from pathlib import Path


def write_file(file, path):
    file = file.replace("mod_template", new_mod_name)
    file = file.replace("mod_template_templates", new_mod_name + "_templates")
    file = file.replace("mod_template_scripts", new_mod_name + "_scripts")

    with open(path, "w", encoding="utf-8") as f:
        f.write(file)


def main():
    output_dir = Path(new_mod_name)

    output_dir.mkdir(exist_ok=True)

    with open("mod_template/mod_template.lua", "r", encoding="utf-8") as f:
        file = f.read()

        write_file(file, output_dir / f"{new_mod_name}.lua")

    with open("mod_template/mod_template_templates.lua", "r", encoding="utf-8") as f:
        file = f.read()

        write_file(file, output_dir / f"{new_mod_name}_templates.lua")

    with open("mod_template/mod_template_scripts.lua", "r", encoding="utf-8") as f:
        file = f.read()

        write_file(file, output_dir / f"{new_mod_name}_scripts.lua")


if __name__ == "__main__":
    try:
        global new_mod_name
        new_mod_name = input("请输入新的mod名称> ")

        main()
    except Exception as e:
        traceback.print_exc()

    input("程序运行完毕, 按回车键退出> ")
