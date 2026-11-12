# Run Python on CSF3

Job script templates for running Python on the University of Manchester CSF3
cluster. Copy one into your job folder, edit the top two sections, upload the
folder and submit.

| Template | Use it for |
| --- | --- |
| [templates/gpu_job.sh](templates/gpu_job.sh) | Training an ML model on a GPU |
| [templates/cpu_job.sh](templates/cpu_job.sh) | Generating data or any CPU-only Python script |
| [templates/array_job.sh](templates/array_job.sh) | Running one script many times (seeds, parameter sweeps, chunks) |

## Choosing hardware

| You need | Set `-p` to | Cores (`-n`) | RAM per core | Max time (`-t`) |
| --- | --- | --- | --- | --- |
| GPU, A100 80GB | `gpuA` | up to 12 per GPU | about 10GB | `4-0` |
| GPU, L40S 48GB | `gpuL` | up to 12 per GPU | about 10GB | `4-0` |
| One CPU core | `serial` | 1 | 5-6GB | `7-0` |
| Several CPU cores | `multicore` | 2-168 | 8GB | `7-0` |
| Lots of memory | `himem` | 1-32 | 32GB | `7-0` |

- GPUs: `-G` sets how many. You can have at most 4 in use at once.
- There is no separate memory setting in these templates: memory comes with
  cores, so ask for more cores if you run out.
- Time is written `days-hours`. It is required, and the job is killed when it
  runs out, so save checkpoints during long training runs.
- Shorter time and fewer resources usually mean a shorter wait in the queue.

## Once only: create your Python environment on CSF3

Jobs cannot download anything, so install packages from the login node:

```bash
module load apps/binapps/anaconda3/2024.10
conda create -n myenv python=3.12
source activate myenv
pip install --isolated torch numpy     # whatever your scripts import
```

## Each job

1. Put your `.py` files, data and config in one folder, with a copy of a
   template. Use relative paths in your Python code (`data/train.csv`, not
   `C:\Users\...`).
2. Edit sections 1 and 2 of the template.
3. Upload the folder to `~/scratch` on CSF3 (fast, no quota, but files
   untouched for 90 days are deleted and there is no backup, so copy results
   you want to keep back to your home directory or laptop):
   ```bash
   scp -r my_job_folder USERNAME@csf3.itservices.manchester.ac.uk:~/scratch/
   ```
4. Log in, go to the folder and submit:
   ```bash
   cd ~/scratch/my_job_folder
   sbatch gpu_job.sh
   ```

## Watching a job

```bash
squeue -u $USER          # your jobs: PD = waiting, R = running
tail -f train-12345.out  # follow the log (Ctrl+C to stop following)
scancel 12345            # cancel job 12345
```

## Windows users

Job scripts must use Unix (LF) line endings. If a job fails with
`$'\r': command not found`, fix the file on CSF3 with `dos2unix gpu_job.sh`.
In VS Code, the `CRLF`/`LF` indicator at the bottom right switches it.

Source: [CSF3 documentation](https://ri.itservices.manchester.ac.uk/csf3/).
