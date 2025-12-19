import traceback, shutil
from pathlib import Path


input_path = Path("mod_template")


def copy_template(output_dir):
    return shutil.copytree(input_path, output_dir)


def replace_file(file, output_dir, new_mod_name):
    file = file.replace("mod_template", new_mod_name)

    with open(output_dir, "w", encoding="utf-8") as f:
        f.write(file)


def rename_mod(output_file, relace_path):
    relace_path.rename(output_file)


def main():
    new_mod_name = input("请输入新的mod名称> ")

    output_dir = Path(new_mod_name)

    copy_template(output_dir)

    require_replaced_file = [
        (output_dir / "mod_template.lua", ""),
        (output_dir / "mod_template_templates.lua", "_templates"),
        (output_dir / "mod_template_scripts.lua", "_scripts"),
    ]

    for relace_path, suffix in require_replaced_file:
        with open(relace_path, "r", encoding="utf-8") as f:
            file = f.read()

        replace_file(file, relace_path, new_mod_name)

        rename_mod(output_dir / f"{new_mod_name}{suffix}.lua", relace_path)


if __name__ == "__main__":
    try:
        main()
    except Exception as e:
        traceback.print_exc()

    input("程序运行完毕, 按回车键退出> ")
