#!/bin/bash --login
# =============================================================================
# CSF3 CPU job template (e.g. generating data with a Python script)
# Submit from inside your job folder on CSF3 with:   sbatch cpu_job.sh
# Lines starting with "#SBATCH" are NOT comments: they are requests to the
# scheduler. To switch one off, change it to "##SBATCH".
# =============================================================================

# ---- 1. HARDWARE REQUEST (edit these) ---------------------------------------
#SBATCH -J generate           # Job name (shows up in the queue and log name)
#SBATCH -p multicore          # Queue: multicore = 2 to 168 cores, 8GB RAM each
#SBATCH -n 4                  # CPU cores. Only ask for more than your code
                              #   really uses; idle cores can get a job cancelled.
#SBATCH -t 0-12               # Time limit, days-hours. 0-12 = 12 hours. Max 7-0.
#SBATCH -o %x-%j.out          # Log file: <jobname>-<jobid>.out (prints + errors)

# If your script uses just ONE core (plain Python with no multiprocessing):
#   change "-p multicore" to "-p serial" and "-n 4" to "-n 1"   (5-6GB RAM)
# If you run out of memory: ask for more cores, or use "-p himem" (32GB/core).

# ---- 2. WHAT TO RUN (edit these) --------------------------------------------
CONDA_MODULE="apps/binapps/anaconda3/2024.10"   # Python 3.12
ENV_NAME="myenv"              # Your conda environment (created on login node)
SCRIPT="generate.py"          # Python file to run, relative to this folder
ARGS=""                       # Extra arguments, e.g. "--n-samples 10000"

# ---- 3. SETUP AND RUN (normally no need to edit) ----------------------------
module purge
module load "$CONDA_MODULE"
source activate "$ENV_NAME" || { echo "ERROR: conda env '$ENV_NAME' not found"; exit 1; }

# Let numpy etc. use the cores requested. In your own multiprocessing code,
# read the core count with:  int(os.environ["SLURM_NTASKS"])
export OMP_NUM_THREADS=$SLURM_NTASKS

echo "Job $SLURM_JOB_ID started on $(hostname) at $(date)"
echo "Folder: $(pwd)   Cores: $SLURM_NTASKS"

# -u makes print() output appear in the log immediately.
python -u "$SCRIPT" $ARGS
STATUS=$?

echo "Job finished at $(date) with exit code $STATUS (0 means success)"
exit $STATUS
