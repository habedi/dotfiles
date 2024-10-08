# Template for Python Projects

[![Tests](https://github.com/habedi/template-python-project-repo/actions/workflows/tests.yml/badge.svg)](https://github.com/habedi/template-python-project-repo/actions/workflows/tests.yml)
[![Made with Love](https://img.shields.io/badge/Made%20with-Love-red.svg)](https://github.com/habedi/template-python-project-repo)

This repository is as a template for starting Python projects. It includes a basic structure for organizing the things
like code,
data, and notebooks, as well as a configuration file for managing the dependencies using Poetry. The repository also
includes a GitHub Actions workflow for running tests on the codebase.

I made it mainly for my personal and professional machine learning data science projects, but feel free to use it
as a starting point for your own projects if you find it useful.

## Installing Poetry

We use [Poetry](https://python-poetry.org/) for managing the dependencies and virtual environment for the project. To
get
started, you need to install Poetry on your machine. We can install Poetry by running the following command in the
command
line using pip.

```bash
pip install poetry
```

When the installation is finished, run the following command in the shell in the root folder of this repository to
install the dependencies, and create a virtual environment for the project.

```bash
poetry install
```

After that, enter the Poetry environment by invoking the poetry shell command.

```bash
poetry shell
```

## Folder Structure

The repository has the following structure:

- `bin/`: scripts and executables for command line use
- `data/`: data files and datasets
- `src/`: source code files
- `notebooks/`: Jupyter notebooks files
- `models/`: trained models and model files
- `tests/`: test files for the source code
- `pyproject.toml`: project metadata and dependencies
- `LICENSE`: license information
- `README.md`: project information and instructions

## License

Files in this repository are licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
