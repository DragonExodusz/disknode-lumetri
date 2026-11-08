# DiskNode

Static website for the DiskNode diskless-boot platform.

## Run locally

Open the workspace in Visual Studio Code, select **Run DiskNode locally** in
Run and Debug, and press **F5**. The site will open at `http://localhost:4173/`.

The website can also be hosted directly on GitHub Pages or imported into Vercel.
Neither hosting provider requires a framework or build step.

## Publish on GitHub Pages

In the repository, open **Settings → Pages**, select **Deploy from a branch**,
choose the `main` branch and `/ (root)` folder, then save. GitHub will display
the public website URL in the Pages settings.

## Publish on Vercel

Import the GitHub repository as a new Vercel project. Keep the framework preset
as **Other** and leave the build and output directory fields empty to serve this
static site from the project root.
