#!/bin/bash

install_conda=1
inmt=0
installation_path=""

##########################
#### Parse  arguments ####
##########################
while getopts "p:ie:" opt; do
    case ${opt} in
	p )
	    installation_path="$OPTARG"
	    ;;
	i )
	    inmt=1
	    ;;
	e )
	    install_conda=0
	    env_name="$OPTARG"
	    ;;
	\? )
	    >&2 echo "Usage: $0 installation_path {options}."
	    >&2 echo "Options:"
	    >&2 echo "  -i: set up INMT branch."
	    >&2 echo "  -e env_name: create a new conda environment named env_name (default: install conda.)."
	    exit 1
	    ;;
    esac
done

if [[ "$installation_path" == "" ]]
then
    >&2 echo "Usage: $0 installation_path {options}."
    >&2 echo "Options:"
    >&2 echo "  -i: set up INMT branch."
    >&2 echo "  -e env_name: create a new conda environment named env_name (default: install conda.)."
    exit 1
fi

if [[ ! -d "$installation_path" ]]
then
    >&2 echo "Error: path $installation_path does not exist."
    exit 1
fi


if [[ $install_conda == 1 && ("$PYTHONPATH" == *"conda"* || "$PATH" == *"conda"*) ]]
then
    >&2 echo "Error: Conda seems to be already installed and set in your PATH and/or PYTHONPATH."
    exit 1
fi

if [[ $install_conda == 0 && ! $(command -v conda) ]]
then
    >&2 echo "Error: Conda does not seem to be install."
    exit 1
fi

export PTH="$installation_path"/NMT-Keras
mkdir -p "$PTH"
if [[ ! -d "$PTH" ]]
then
    >&2 echo "Error: installation directory could not be created. You may need sudo permisions to install in $installation_path."
    exit 1
fi

##########################
# NMT-Keras installation #
##########################
git clone https://github.com/lvapeab/nmt-keras.git "$PTH"/nmt-keras

##########################
# miniconda installation #
##########################
if [[ $install_conda == 1 ]]
then
    wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
    bash miniconda.sh -b -p "$PTH"/miniconda
    export PATH="$PTH/miniconda/bin:$PATH"
    hash -r
    conda config --set always_yes yes --set changeps1 no
    conda update -q conda
    conda info -a
    conda init
    . ~/.bashrc
    rm miniconda.sh
else
    conda create -n "$env_name" python=3.7
    eval "$(conda shell.bash hook)"
    conda activate "$env_name"
fi

##########################
# NMT-Keras requirements #
##########################
pip install --upgrade pip
pip install -e "$PTH"/nmt-keras

##########################
### INMT  requirements ###
##########################
if [[ $inmt == 1 ]]
then
    git clone --branch Interactive_NMT https://github.com/lvapeab/multimodal_keras_wrapper.git "$PTH"/Interactive_NMT
    export PYTHONPATH=$PYTHONPATH:"$PTH"/Interactive_NMT
    pip install -r "$PTH"/Interactive_NMT/requirements.txt
    echo "Remember to add $PTH/Interactive_NMT to your PYTHONPATH."
fi
