#!/bin/bash --login
# =============================================================================
# CSF3 job array template: run the SAME script many times with a different
# task number each time (parameter sweeps, random seeds, data in chunks).
# Submit from inside your job folder on CSF3 with:   sbatch array_job.sh
# Lines starting with "#SBATCH" are NOT comments: they are requests to the
# scheduler. To switch one off, change it to "##SBATCH".
# =============================================================================

# ---- 1. HARDWARE REQUEST, PER TASK (edit these) -----------------------------
#SBATCH -J sweep              # Job name
#SBATCH -a 1-10%5             # Task numbers 1 to 10, at most 5 running at once.
                              #   Highest allowed task number is 25000.
#SBATCH -p serial             # Each task gets 1 core, 5-6GB RAM
#SBATCH -n 1
#SBATCH -t 0-4                # Time limit for EACH task, days-hours
#SBATCH -o %x-%A_%a.out       # One log per task: <jobname>-<jobid>_<task>.out

# For GPU tasks instead, replace the "-p serial" and "-n 1" lines with:
#   #SBATCH -p gpuA
#   #SBATCH -G 1
#   #SBATCH -n 8
# and keep the "%N" limit above at 4 or below (4 GPUs max at once).

# ---- 2. WHAT TO RUN (edit these) --------------------------------------------
CONDA_MODULE="apps/binapps/anaconda3/2024.10"   # Python 3.12
ENV_NAME="myenv"              # Your conda environment (created on login node)
SCRIPT="generate.py"          # Python file to run, relative to this folder
# Your script receives the task number; use it as a seed, a row of a
# parameter table, a chunk index, and to give each task its own output file.
ARGS="--task-id $SLURM_ARRAY_TASK_ID"

# ---- 3. SETUP AND RUN (normally no need to edit) ----------------------------
module purge
module load "$CONDA_MODULE"
source activate "$ENV_NAME" || { echo "ERROR: conda env '$ENV_NAME' not found"; exit 1; }

export OMP_NUM_THREADS=$SLURM_NTASKS

echo "Task $SLURM_ARRAY_TASK_ID of job $SLURM_ARRAY_JOB_ID started on $(hostname) at $(date)"

python -u "$SCRIPT" $ARGS
STATUS=$?

echo "Task finished at $(date) with exit code $STATUS (0 means success)"
exit $STATUS
