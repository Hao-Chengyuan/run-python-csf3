#!/bin/bash --login
# =============================================================================
# CSF3 GPU job template (e.g. training an ML model)
# Submit from inside your job folder on CSF3 with:   sbatch gpu_job.sh
# Lines starting with "#SBATCH" are NOT comments: they are requests to the
# scheduler. To switch one off, change it to "##SBATCH".
# =============================================================================

# ---- 1. HARDWARE REQUEST (edit these) ---------------------------------------
#SBATCH -J train              # Job name (shows up in the queue and log name)
#SBATCH -p gpuA               # GPU type: gpuA = A100 80GB, gpuL = L40S 48GB
#SBATCH -G 1                  # Number of GPUs (you may use at most 4 at once)
#SBATCH -n 8                  # CPU cores (max 12 per GPU). RAM comes with
                              #   cores: about 10GB per core, 125GB max per GPU
#SBATCH -t 1-0                # Time limit, days-hours. 1-0 = 1 day. Max is 4-0.
                              #   The job is killed when this runs out.
#SBATCH -o %x-%j.out          # Log file: <jobname>-<jobid>.out (prints + errors)

# ---- 2. WHAT TO RUN (edit these) --------------------------------------------
CONDA_MODULE="apps/binapps/anaconda3/2024.10"   # Python 3.12
CUDA_MODULE=""                # Leave empty if you pip-installed PyTorch (it
                              #   brings its own CUDA). Otherwise e.g.
                              #   "libs/cuda/12.4.1", or "libs/cuDNN/9.11.0"
                              #   (which also loads CUDA 12.8.1).
ENV_NAME="myenv"              # Your conda environment (created on login node)
SCRIPT="train.py"            # Python file to run, relative to this folder
ARGS=""                       # Extra arguments, e.g. "--config config.yaml"

# ---- 3. SETUP AND RUN (normally no need to edit) ----------------------------
module purge
module load "$CONDA_MODULE"
if [ -n "$CUDA_MODULE" ]; then module load "$CUDA_MODULE"; fi
source activate "$ENV_NAME" || { echo "ERROR: conda env '$ENV_NAME' not found"; exit 1; }

# Let numpy / PyTorch data loaders use the CPU cores that were requested.
export OMP_NUM_THREADS=$SLURM_NTASKS

echo "Job $SLURM_JOB_ID started on $(hostname) at $(date)"
echo "Folder: $(pwd)   Cores: $SLURM_NTASKS   GPUs: $CUDA_VISIBLE_DEVICES"
nvidia-smi

# -u makes print() output appear in the log immediately.
python -u "$SCRIPT" $ARGS
STATUS=$?

echo "Job finished at $(date) with exit code $STATUS (0 means success)"
exit $STATUS
