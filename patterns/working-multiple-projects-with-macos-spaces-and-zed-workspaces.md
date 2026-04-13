# Working Multiple Projects with macOS Spaces and Zed Workspaces

Touching multiple projects with AI assistance is increasingly viable, especially because multiple projects naturally have different concerns. But a workflow still needs to be tried to get this right.

## The Problem

Separating projects by windows (open each in a separate IDE window) is the simplest organization but quickly breaks down: your desktop gets messy fast.

## Solution: OS-Level Spaces

Use "Spaces" (macOS) or equivalent:
- macOS: Spaces
- Windows: Virtual Desktops
- Linux: Workspaces (Ubuntu terminology)

### Example Setup: 3 Project Areas

| Space | Area |
|-------|------|
| 1 | Personal |
| 2 | Work (default) |
| 3 | Side projects |

Stay on Space 2 (work) most of the time. While waiting for work tasks to finish (e.g., compiling), switch left to Space 1 or right to Space 3. The gesture is instant and keeps context separate.

## Push Further with Zed Workspaces

What if you have multiple sub-projects within each area? For example:
- Personal: blog site, landing page
- Work: project A, project B
- Side: etc.

Zed has a "workspaces" feature (toggle with `cmd+opt+j`) that shows workspaces in the left sidebar. Switching between sub-projects is instant, and both sub-projects share one Zed window — keeping the desktop clean.

## Result

- Spaces: isolate top-level concerns (personal / work / side)
- Zed workspaces: manage sub-projects within each area without window sprawl

This combination keeps focus in what can easily become a chaotic multi-project environment.
