from setuptools import find_packages, setup

setup(
    name="retailflow_orchestration",
    packages=find_packages(exclude=["retailflow_orchestration_tests"]),
    install_requires=[
        "dagster",
        "dagster-cloud"
    ],
    extras_require={"dev": ["dagit", "pytest"]},
)
