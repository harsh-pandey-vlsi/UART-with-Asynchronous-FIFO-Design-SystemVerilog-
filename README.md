# UART with Asynchronous FIFO (SystemVerilog)

## 📌 Overview
This project implements a **UART RX–TX system with an asynchronous FIFO** using **SystemVerilog RTL**.
The design safely transfers UART data between two independent clock domains.

Only the **design (RTL)** is implemented.  
The code is **lint-clean and synthesizable** and has been verified through **Vivado synthesis**.

---

## 🧩 Architecture

UART RX (rx_clk)
        |
        v
+----------------+
|  UART RX       |
+----------------+
        |
        v
+----------------+
| Async FIFO     |  ← Clock Domain Crossing
+----------------+
        |
        v
+----------------+
| UART TX        |
+----------------+
        |
        v
UART TX (tx_clk)

---

## ✨ Features
- UART RX and TX FSM-based implementation
- Asynchronous FIFO using Gray-code pointers
- Clean clock-domain crossing (CDC-safe)
- Fully synthesizable SystemVerilog RTL
- Successfully synthesized in **Xilinx Vivado**

---

## 🛠️ Modules

| Module | Description |
|------|-------------|
| `uart_rx.sv` | UART receiver FSM |
| `uart_tx.sv` | UART transmitter FSM |
| `async_fifo.sv` | Asynchronous FIFO (dual-clock) |
| `uart_fifo_top.sv` | Top-level integration |

---

## 🔧 Tools Used
- **Language:** SystemVerilog
- **EDA Tool:** Xilinx Vivado
- **Target:** FPGA-synthesizable RTL

---

## 🚧 Project Scope
✔ RTL Design  
✔ Linting  
✔ Synthesis  

❌ Testbench / UVM  
❌ Functional Coverage  
❌ Assertions  

*(Verification intentionally out of scope for this version.)*

---

## 📈 Future Enhancements
- SystemVerilog/UVM-based verification
- Assertions and functional coverage
- Configurable baud-rate generator
- AXI-stream interface

---

## 👤 Author
**Harsh Pandey**  
ECE student | VLSI & Digital Design

---

## 📜 License
MIT License
