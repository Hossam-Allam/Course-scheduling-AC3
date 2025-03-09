# AC3 Algorithm and Course Scheduling Project Overview

This document provides an overview of the AC3 (Arc Consistency 3) algorithm and explains how it is applied in our course scheduling project. The project uses a combination of constraint propagation (via AC3) and backtracking search to assign rooms and periods to courses while satisfying a variety of constraints.

---

## AC3 Algorithm Overview

The AC3 algorithm is a popular method in constraint satisfaction problems (CSPs) for enforcing **arc consistency** between pairs of variables. In our context, variables represent course sessions, and their domains include possible room and period assignments.

### Key Concepts

- **Variables and Domains:**  
  Each course session is a variable, with its domain being a set of potential room assignments and period values.

- **Binary Constraints:**  
  Constraints are defined between pairs of variables. Examples include:
  - A lecture must be scheduled before its corresponding lab.
  - A professor cannot teach two courses at the same period.

- **Arc Consistency:**  
  For a binary constraint between variables `X` and `Y`, a value `x` in the domain of `X` is arc-consistent with `Y` if there exists some value `y` in the domain of `Y` such that the constraint between `X` and `Y` is satisfied.

### How AC3 Works

1. **Initialization:**  
   - A queue is created containing all arcs (pairs of variables that share a constraint).

2. **Propagation (Revise Step):**  
   - For each arc `(Xi, Xj)`, the algorithm checks whether every value in `Xi`'s domain is consistent with some value in `Xj`'s domain.
   - Values from `Xi`'s domain that have no supporting value in `Xj`'s domain are removed.

3. **Reinforcement:**  
   - If a domain is revised (i.e., a value is removed), all arcs pointing to that variable (other than the current one) are re-added to the queue for re-checking.

4. **Termination:**  
   - The algorithm terminates when the queue is empty. If any variable's domain becomes empty, the problem is unsolvable.

#### Example Constraint
For a lecture–lab ordering constraint:
- **Constraint:** `lecture_period < lab_period`
- AC3 will remove any lecture period value that does not have a corresponding lab period value that is greater.

---

## Course Scheduling Project

Our scheduling project uses AC3 to prune the domains before a backtracking search assigns each course a room and period. This two-step approach makes the search more efficient by reducing the number of candidate assignments.

### Main Constraints in the Project

- **Room Capacity:**  
  Each course has an enrollment requirement, and rooms are pre-filtered to include only those with sufficient capacity.  
  Additionally, lab courses may be restricted to lab-designated rooms.

- **Time Constraints:**  
  For courses with both lectures and labs, the lecture must occur before the lab.

- **Professor Constraints:**  
  A professor cannot be assigned to teach two courses at the same period.

- **Group Constraints:**  
  For example, courses with names starting with `"CHEM"` should not be scheduled during the same period.

### Project Workflow

1. **Domain Initialization and Pre-Pruning:**  
   - Build a domain for each course session, separating room and period possibilities.
   - Pre-prune room domains by checking room capacity (and, for lab courses, matching room names).

2. **AC3 Propagation:**  
   - Use the AC3 algorithm to enforce binary constraints (like lecture–lab ordering) and reduce the period domains accordingly.

3. **Backtracking Search:**  
   - Use a backtracking algorithm that explores the Cartesian product of the remaining room and period domains.
   - Each candidate assignment is checked for consistency against all constraints.

4. **Selective Checks via Auxiliary Data Structures:**  
   - For example, an auxiliary hash (`courses_in_period`) is maintained to quickly check group constraints (e.g., ensuring no two CHEM courses are in the same period).


