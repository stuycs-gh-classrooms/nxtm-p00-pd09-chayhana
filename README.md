[![Review Assignment Due Date](https://classroom.github.com/assets/deadline-readme-button-22041afd0340ce965d47ae6ef1cefeee28c7c493a6346c4f15d667ab976d596c.svg)](https://classroom.github.com/a/rXX1_Uiw)
## Project 00
### NeXTCS
### Period: 9
## Name0: Solomon Binyaminov
## Name1: Nisan Safanov
## Name2: Seongjae Oh
---

This project will be completed in phases. The first phase will be to work on this document. Use github-flavoured markdown. (For more markdown help [click here](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet) or [here](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax) )

All projects will require the following:
- Researching new forces to implement.
- Method for each new force, returning a `PVector`  -- similar to `getGravity` and `getSpring` (using whatever parameters are necessary).
- A distinct demonstration for each individual force (including gravity and the spring force).
- A visual menu at the top providing information about which simulation is currently active and indicating whether movement is on or off.
- The ability to toggle movement on/off
- The ability to toggle bouncing on/off
- The user should be able to switch _between_ simluations using the number keys as follows:
  - `1`: Gravity
  - `2`: Spring Force
  - `3`: Drag
  - `4`: Custom Force
  - `5`: Combination


## Phase 0: Force Selection, Analysis & Plan
---------- 

#### Custom Force: Electric Force

### Formula
What is the formula for your force? Including descriptions/definitions for the symbols. (You may include a picture of the formula if it is not easily typed.)

(K * q1 * q2)/r^2
K is Coulomb's constant (8.99 × 10^9)
q1 and q2 are the two values of involved charges
r is the distance between involved charges

### Electrical Force (Custom)
- What information that is already present in the `Orb` or `OrbNode` classes does this force use?
  - Distance

- Does this force require any new constants, if so what are they and what values will you try initially?
  - Coulomb's constant

- Does this force require any new information to be added to the `Orb` class? If so, what is it and what data type will you use?
  - Charge values, use data type int.

- Does this force interact with other `Orbs`, or is it applied based on the environment?
  - Yes, it interacts with other orbs.

- In order to calculate this force, do you need to perform extra intermediary calculations? If so, what?
  - Distance

--- 

### Simulation 1: Gravity
The gravity simulation will focus on orbital motion, demonstrating how celestial bodies interact through gravitational attraction. By varying initial velocities and masses, the simulation will showcase different orbital paths, from circular to elliptical trajectories.

--- 

### Simulation 2: Spring
Describe what your spring simulation will look like. Explain how it will be setup, and how it should behave while running.

The spring force simulation will explore oscillatory motion, implementing Hooke's law to model spring behavior. Users will be able to observe how different spring constants affect object motion.

--- 

### Simulation 3: Drag
Describe what your drag simulation will look like. Explain how it will be setup, and how it should behave while running.

Drag force simulation will model fluid resistance, showing how objects decelerate when moving through a fluid environment. By varying parameters such as fluid density and object shape, the simulation will provide insights into how drag affects object trajectories and movement.

--- 

### Simulation 4: Custom force
Describe what your Custom force simulation will look like. Explain how it will be setup, and how it should behave while running.

The custom electric force simulation will visualize electromagnetic interactions between charged particles. Users will be able to observe attraction and repulsion based on charge values, with the force strength directly related to the magnitude of the charges.

--- 

### Simulation 5: Combination
Describe what your combination simulation will look like. Explain how it will be setup, and how it should behave while running.

The combination simulation represents integrating gravity, spring, drag, and electric forces into a single, complex environment. This simulation will demonstrate how multiple forces can interact simultaneously, creating  behaviors that highlight the integration of all coded physical systems.

