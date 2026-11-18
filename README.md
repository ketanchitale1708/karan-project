# WasteFlow – Smart Waste Management & Route Intelligence

WasteFlow is a full-stack, enterprise-grade intelligent waste collection management and route optimization application. It combines automated IoT fill telemetry, priority-based collection queuing, Dijkstra shortest-path route planning over road network graphs, an interactive 2D Canvas and 3D Three.js WebGL visual dashboard, a standalone Java Swing operator workstation, and processor-level x86-64 native assembly simulation.

---

## Academic Course Outcome (CO4) Implementation Matrix

WasteFlow features a unified, dedicated **Academic CO4 Demonstration** dashboard module covering all four curriculum subjects:

| Subject | Academic CO4 Requirement | Key Implemented Features | Source Location |
|---|---|---|---|
| **Programming Lab (PL)** | Searching, Sorting & Hashing with collision handling and empirical benchmarking (CO4 & CO5) | `BinCodeHashIndex` open addressing with linear probing, Bubble/Insertion/Selection/Merge Sort, multi-field sorting, and non-fabricated `System.nanoTime()` performance benchmarks across Small, Medium, Large datasets. | `backend/.../bin/BinCodeHashIndex.java`<br>`backend/.../bin/BinSortAlgorithms.java`<br>`backend/.../bin/AlgorithmBenchmarkService.java` |
| **PSOOP (Java)** | File handling and Java generics applied to real-world case study execution | Reusable generic `CsvFileWriter<T>` utilizing `Function<? super T, ? extends List<String>>` for Route Reports, Bins Register, Fleet Trucks, and Collection Requests. Robust UTF-8 buffered streaming, RFC-4180 escaping, and guaranteed temporary file cleanup in `finally`. File reader and verification suite. | `backend/.../report/CsvFileWriter.java`<br>`backend/.../report/DataExportService.java`<br>`backend/.../report/RouteReportService.java`<br>`backend/.../report/DataExportController.java` |
| **COA** | Processor-level integration and mapping using CPU Simulator and 64-bit Assembly | Maps bin classification, route totals, repeated workload, and route-string processing to x86-64 general-purpose registers (`RAX`, `RBX`, `RCX`, `RDX`, `RSI`, `RDI`), ALU instructions (`ADD`, `IMUL`, `IDIV`, `CMP`), condition flags (ZF, SF, CF, OF), and branching (`JGE`, `JNZ`, `HLT`). Cross-verified against native MinGW GCC compiled binary. | `backend/.../coa/CoaSimulationService.java`<br>`backend/.../coa/NativeCoaExecutor.java`<br>`backend/.../coa/X64InstructionSimulator.java`<br>`backend/src/main/resources/coa/native/*.S` |
| **Computer Graphics (CG)** | Complete application rendering, texture mapping, coordinate alignment, and transformation precision | Dual-mode 2D Canvas (Bresenham lines, midpoint circles, Cohen-Sutherland line clipping) and 3D WebGL (Three.js meshes, procedural asphalt and terrain texture mapping, directional sunlight with shadow maps, status glows, truck spotlights, and route heading rotation). | `frontend/src/RouteCanvas.tsx`<br>`frontend/src/RouteScene3D.tsx`<br>`frontend/src/graphicsAlgorithms.ts` |

---

## System Architecture

```text
  React 19 + TypeScript + Vite + Three.js / HTML Canvas Frontend
                                |
                                | REST JSON APIs (UTF-8)
                                v
               Spring Boot 4.1.1 (Java 21) Backend
       +---------------------------------------------------+
       |  - Bin Network Management & BinCodeHashIndex      |
       |  - Route Planning (Dijkstra Shortest Path Graph)   |
       |  - Custom Generic CsvFileWriter<T> File Handling   |
       |  - Algorithm Benchmark Suite (Sorting & Searching)|
       |  - COA Simulator & Native x86-64 GCC Assembler    |
       +---------------------------------------------------+
                                |
             +------------------+------------------+
             v                                     v
     MySQL / H2 (JPA)               Stand-Alone Desktop Client
  (Flyway Migrations V1-V4)              (Java Swing GUI)
```

---

## Instructions to Run

### Prerequisites
- **Java Development Kit (JDK 21 or later)**
- **Node.js (v18+) & npm**
- **C Compiler (Optional for COA Native)**: 64-bit MinGW GCC (`x86_64-w64-mingw32-gcc`)

### 1. Backend Application (Spring Boot)
Open a terminal in `backend`:
```powershell
Set-Location "backend"
.\mvnw.cmd spring-boot:run
```
The backend starts on `http://localhost:8080`.

### 2. Frontend Application (React + Vite)
Open a separate terminal in `frontend`:
```powershell
Set-Location "frontend"
npm install
npm run dev
```
The frontend interface starts on `http://localhost:5173`.

### 3. Run Backend Unit Tests
To execute all 68 automated unit and integration tests:
```powershell
Set-Location "backend"
.\mvnw.cmd test
```

### 4. Standalone Desktop Client (Java Swing)
To package and launch the desktop operations client:
```powershell
.\backend\mvnw.cmd -f desktop\pom.xml package
java -jar desktop\target\wasteflow-desktop.jar
```

---

## REST Endpoints Overview

### File Handling & Generics (PSOOP CO4)
- `GET /api/reports/routes/{id}.csv`: Exports waste collection route report with stops and weights.
- `GET /api/reports/bins.csv`: Exports all active waste bins with fill percentage and urgency status.
- `GET /api/reports/trucks.csv`: Exports fleet vehicle capacity and statuses.
- `GET /api/reports/requests.csv`: Exports prioritized collection requests queue.
- `POST /api/reports/verify`: Reads back and parses CSV bytes to verify UTF-8 encoding and RFC-4180 compliance.

### Searching, Sorting & Hashing (PL CO4 & CO5)
- `GET /api/bins/by-code?code={binCode}`: Exact bin lookup via `BinCodeHashIndex` (O(1)).
- `GET /api/bins?sortBy={field}&algorithm={algo}`: Selectable sorting by fill level, code, or location using Bubble, Insertion, Selection, or Merge Sort.
- `GET /api/pl/benchmark?size={N}`: Empirical benchmark comparing all sorting and searching algorithms with nanosecond timings.
- `GET /api/pl/hash-inspect`: Returns live internal hash table slots, load factor, and collision count.

### Computer Organization & Architecture (COA CO4)
- `POST /api/coa/bin-status`: Processor registers and ALU classification of bin fill level.
- `POST /api/coa/route-totals`: 64-bit accumulator addition of route distance and travel time.
- `POST /api/coa/route-workload`: Successive addition loop with `DEC RCX` and `JNZ`.
- `POST /api/coa/route-summary`: Null-terminated string processing via `LODSB` and `STOSB`.

---

## Project Verification & Faculty Evaluation Guide

1. **Academic CO4 Demonstration Tab**: Click the **Academic CO4** tab in the main sidebar.
2. **PL Tab**:
   - Run exact hash search (`BIN-001`) vs missing search (`BIN-999`).
   - Run live sorting with Merge Sort.
   - Click "Run Benchmark" with N=25, N=100, N=500 to see real CPU execution times.
   - Click "Inspect Live Hash Index" to view table slots and linear probing displacements.
3. **PSOOP Tab**:
   - Click "Export Bins CSV", "Export Trucks CSV", or "Export Route CSV" to download actual database records.
   - Click "Verify CSV File Read & Parse" to verify `CsvFileWriter.read()` round-trip parsing.
4. **COA Tab**:
   - Select a bin and run count, click "Run CO4 Processor Mapping".
   - Review assembly instructions, register values, ALU flags, and native x86-64 verification badges.
5. **Computer Graphics Tab**:
   - Toggle between 2D Canvas and 3D Three.js WebGL rendering.
   - Verify coordinate precision in the alignment table.
   - Play truck animation to verify forward heading rotation along route segments.
