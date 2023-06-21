## Making Changes to `generate_fake_data.py`

If you make changes to `generate_fake_data.py` and need to prepare it for deployment again, you can follow these steps:

1. **Ensure you're inside the `/generate` directory.**
    - Run `cd generate` from the project's root directory.

2. **Remove previous package and function.zip files, if they exist.**
    - Run `rm -rf package function.zip`

3. **Install the required Python packages.**
    - Run `pip install -r requirements.txt -t ./package/`
    - This installs the packages listed in `requirements.txt` into the `./package/` directory.

4. **Copy your updated script to the `./package/` directory.**
    - Run `cp generate_fake_data.py ./package/`

5. **Change into the `package` directory.**
    - Run `cd package`

6. **Create a zip file for deployment.**
    - Run `zip -r ../function.zip .`
    - This creates a zip file named `function.zip` at the root of `generate` directory that contains the contents of `./package/`.

Please ensure that you have the necessary permissions to run these commands on your system.