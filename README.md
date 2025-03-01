# 🚀 Tic-Tac-Toe in Assembly (x86)

This repository contains an **x86 Assembly implementation** of the classic **Tic-Tac-Toe** game, featuring **graphical rendering using Canvas library** and **event-driven gameplay**. The game runs in a **graphical window** where players can click to place their marks (`X` or `O`), and the program automatically checks for a winner.

---

## 📜 Project Overview

### 🎮 Game Features
- **Graphical board rendering** using the **Canvas library**.
- **Mouse click-based gameplay**.
- **Automatic win detection** for `X` and `O` players.
- **Support for grid lines, animations, and visual effects**.
- **Basic event handling for rendering and input processing**.

---

### 🛠️ Implementation Details

The game is implemented using **x86 Assembly (MASM)** and integrates **system-level memory management and low-level drawing functions**.

#### Key Components:
- **Graphical Rendering**:
  - Uses `Canvas.lib` to create a **600x500** window.
  - Custom **line drawing macros** for grid and victory lines.
  - **"X" and "O" symbols drawn pixel-by-pixel**.
- **Event Handling**:
  - Mouse clicks determine **board positions**.
  - Game state is stored in a **3x3 matrix**.
  - Click parity determines **which player’s turn** it is.
- **Win Condition Verification**:
  - Checks **rows, columns, and diagonals** for a winner.
  - Displays a **winning message** when a player wins.
  - If all cells are filled, **the game ends in a draw**.

---

## 🎮 User Controls

| Action | Control |
|--------|---------|
| Click to place `X` or `O` | Left Mouse Click |
| Reset game (on restart) | Close & Reopen |

The game **does not feature AI**, so it is meant for **two human players** taking turns.

