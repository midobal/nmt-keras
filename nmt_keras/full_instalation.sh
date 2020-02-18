#!/bin/bash

if [[ "$#" -gt 2 || "$#" -lt 1 ]]
then
    >&2 echo "Usage: $0 installation_path {-i}."
    >&2 echo "   -i: set up INMT branch."
    exit 1

elif [[ ! -d "$1" ]]
then
    >&2 echo "Error: path $1 does not exist."
    exit 1
fi

if [[ "$#" -eq 2 && ("$1" -eq "-i" || "$2" -eq "-i") ]]
then
    inmt=1
else
    inmt=0
fi
    

if [[ "$PYTHONPATH" == *"conda"* ]]
then
    >&2 echo "Error: Conda seems to be already set in you PYTHONPATH."
    exit 1
fi

export PTH="$1"/NMT-Keras
mkdir -p "$PTH"
if [[ ! -d "$PTH" ]]
then
    >&2 echo "Error: installation directory could not be created. You may need sudo permisions to install in $1."
    exit 1
fi

##########################
# NMT-Keras installation #
##########################
git clone https://github.com/lvapeab/nmt-keras.git "$PTH"/nmt-keras

##########################
# miniconda installation #
##########################
wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh -O miniconda.sh;
bash miniconda.sh -b -p "$PTH"/miniconda
export PATH="$PTH/miniconda/bin:$PATH"
hash -r
conda config --set always_yes yes --set changeps1 no
conda update -q conda
conda info -a
conda init
rm miniconda.sh

##########################
# NMT-Keras requirements #
##########################
conda install --file "$PTH"/nmt-keras/req-travis-conda.txt
conda install mkl mkl-service
pip install -r "$PTH"/nmt-keras/req-travis-pip.txt
pip install tensorflow==1.14.0
echo "Remember to refresh shell session and to add $PTH/nmt-keras/keras to PYTHONPATH."

##########################
### INMT requirements  ###
##########################
if [[ $inmt == 1 ]]
then
    git clone --branch Interactive_NMT https://github.com/lvapeab/multimodal_keras_wrapper.git "$PTH"/Interactive_NMT
    export PYTHONPATH=$PYTHONPATH:"$PTH"/Interactive_NMT
    pip install -r "$PTH"/Interactive_NMT/requirements.txt
    echo "Remember to add $PTH/Interactive_NMT to your PYTHONPATH."
fi
