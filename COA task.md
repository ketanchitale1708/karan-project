# Computer Organization and Architecture Tasks 1, 2, 3, and 4

## Project context

WasteFlow includes a COA Lab that demonstrates processor-level execution using real application data. It can trace bin fill status, route distance/time totals, repeated-route distance, and route stop-code string processing. The CO4 integration action runs the applicable simulations together for the selected bin and current route.

> **Implementation note:** The COA Lab compiles and executes native x86-64 assembly routines with 64-bit MinGW GCC. The Java instruction simulator separately produces the educational register/flag trace; each native result is checked against that trace before it is returned.

## Task 1: Processor-level model of an application

| Concept | Status | Implementation | Source location |
|---|---|---|---|
| Identify application data and operations | Implemented | Bin fill/capacity and route distance/time are used as simulator inputs. | [CoaSimulationService.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationService.java#L24-L32), [CoaSimulationService.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationService.java#L75-L87) |
| Map application operations to processor components | Implemented in simulator | Bin status uses multiply, divide, comparisons, and conditional branches; route totals use addition. | [CoaSimulationService.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationService.java#L33-L56), [CoaSimulationService.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationService.java#L79-L90) |
| Register model | Implemented in simulator | The simulated CPU has 64-bit `RAX`, `RBX`, `RCX`, and `RDX` registers. | [X64InstructionSimulator.java](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L23-L32) |
| ALU operations | Implemented in simulator | `ADD`, `IMUL`, `IDIV`, and `CMP` are interpreted by the CPU simulator. | [X64InstructionSimulator.java](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L60-L71), [X64InstructionSimulator.java](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L154-L194) |
| Status flags | Implemented in simulator | Zero, sign, carry, and overflow flags are tracked and returned. | [X64InstructionSimulator.java](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L17-L22), [X64InstructionSimulator.java](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L279-L282), [CoaSimulationResponse.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationResponse.java#L14-L22) |
| Control unit / instruction flow | Implemented in simulator | Program counter steps through instructions, resolves labels/branches, and stops on `HLT`. | [X64InstructionSimulator.java](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L38-L59), [X64InstructionSimulator.java](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L72-L101) |
| CPU execution trace | Implemented in simulator | Each executed instruction records register and flag state. | [X64InstructionSimulator.java](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L88-L101), [CoaSimulationResponse.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationResponse.java#L17-L22) |
| Simulator interface | Implemented | COA Lab UI runs simulations and displays the result, registers, flags, instruction listing, and trace. | [CoaLab.tsx](frontend/src/CoaLab.tsx#L26-L76), [CoaLab.tsx](frontend/src/CoaLab.tsx#L78-L101), [CoaLab.tsx](frontend/src/CoaLab.tsx#L143-L152) |

### Task 1 workflow

1. Select a WasteFlow bin or use a loaded route.
2. Submit its fill/capacity or distance/time values to the COA API.
3. Convert measurements to integer milli-units for the simulated registers.
4. Interpret the instruction program and update registers/flags.
5. Display the result and per-instruction state in the COA Lab.

## Task 2: 64-bit assembly-based application processing

| Concept | Status | Implementation | Source location |
|---|---|---|---|
| Identify numerical application operations | Implemented | Bin fill-status and route distance/time calculations are selected. | [CoaSimulationService.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationService.java#L24-L72), [CoaSimulationService.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationService.java#L75-L99) |
| First numerical operation: bin status | Implemented natively and cross-checked | Native `imul`, `cqo`, `idiv`, `cmp`, and conditional branches classify the selected bin. | [bin_status.S](backend/src/main/resources/coa/native/bin_status.S), [CoaSimulationService.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationService.java#L24-L72) |
| Second numerical operation: route totals | Implemented natively and cross-checked | Native `add` instructions accumulate each route leg's distance and travel time. | [route_totals.S](backend/src/main/resources/coa/native/route_totals.S), [CoaSimulationService.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationService.java#L75-L99) |
| Connect operations to application data | Implemented | The frontend sends a selected bin's live values or the loaded route totals to the backend. | [CoaLab.tsx](frontend/src/CoaLab.tsx#L21-L50), [api.ts](frontend/src/api.ts#L31-L32) |
| REST endpoints | Implemented | Bin-status and route-total simulation endpoints accept validated input. | [CoaSimulationController.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationController.java#L14-L30), [CoaSimulationRequest.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationRequest.java#L17-L26) |
| Native 64-bit assembly source assembled/executed | Implemented | MinGW GCC assembles the checked-in `.S` routines and links them with a small argument/output bridge; Java runs the resulting x86-64 executable. | [NativeCoaExecutor.java](backend/src/main/java/com/wasteflow/coa/NativeCoaExecutor.java), [native_coa.c](backend/src/main/resources/coa/native/native_coa.c) |

### Supported simulated instruction subset

The teaching simulator interprets `MOV`, `ADD`, `IMUL`, `CQO`, `IDIV`, `CMP`, `JGE`, `JL`, `JMP`, and `HLT`. The instruction dispatch and control flow are in [X64InstructionSimulator.java lines 38–101](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L38-L101), and instruction parsing is in [X64InstructionSimulator.java lines 223–250](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L223-L250).

## Task 3 (CO3): Arithmetic algorithm and string/data processing

### Concepts and locations

| COA Task 3 concept | How it is used | Source location |
|---|---|---|
| Successive addition | Native `add`/`dec`/`jnz` instructions add route distance once per run; the teaching simulator independently traces the same loop. | [route_workload.S](backend/src/main/resources/coa/native/route_workload.S), [CoaSimulationService.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationService.java#L101-L127) |
| Route workload input | The operator selects a repetition count from 1 to 100; the loaded route distance and count are sent to the backend. | [CoaLab.tsx](frontend/src/CoaLab.tsx#L16-L18), [CoaLab.tsx](frontend/src/CoaLab.tsx#L52-L63), [CoaLab.tsx](frontend/src/CoaLab.tsx#L115-L124), [api.ts](frontend/src/api.ts#L33-L33), [CoaSimulationController.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationController.java#L33-L35), [CoaSimulationRequest.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationRequest.java#L28-L32) |
| Route bin-code string processing | Native `lodsb`/`stosb` instructions copy null-terminated bin codes from input memory and add separators; the Java simulator traces the same operation. | [route_summary.S](backend/src/main/resources/coa/native/route_summary.S), [CoaSimulationService.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationService.java#L129-L177) |
| CO3 controls and execution trace | The COA Lab runs both operations and displays the instruction listing, register values, flags, and instruction-by-instruction trace. | [CoaLab.tsx](frontend/src/CoaLab.tsx#L115-L152) |
| Native 64-bit assembly execution | Both CO3 routines are compiled and executed as native x86-64 code; returned values must match the teaching-simulator result. | [NativeCoaExecutor.java](backend/src/main/java/com/wasteflow/coa/NativeCoaExecutor.java), [route_workload.S](backend/src/main/resources/coa/native/route_workload.S), [route_summary.S](backend/src/main/resources/coa/native/route_summary.S) |

CO3 API endpoints:

- `POST /api/coa/route-workload` accepts `{"distanceKm": 3.25, "repetitionCount": 4}` and returns the native repeated-route mileage calculation and simulator trace.
- `POST /api/coa/route-summary` accepts `{"binCodes": ["BIN-01", "BIN-02"]}` and returns the route summary produced by native string instructions.

The supported simulated instruction subset now also includes `DEC`, `JNZ`, `JE`/`JZ`, `TEST`, `LODSB`, and `STOSB` for loops and byte-oriented string processing. Their execution is handled in [X64InstructionSimulator.java lines 60–85](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L60-L85), and supported syntax is parsed in [X64InstructionSimulator.java lines 223–250](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L223-L250).

### API examples

Bin-status simulation:

```http
POST /api/coa/bin-status
Content-Type: application/json

{"currentFillKg": 95, "capacityKg": 100}
```

Route totals simulation:

```http
POST /api/coa/route-totals
Content-Type: application/json

{"legs":[{"distanceKm":3.25,"travelTimeMinutes":4.5},{"distanceKm":2.75,"travelTimeMinutes":5.5}]}
```

## Task 4 (CO4): Integration and Demonstration

### Concepts and locations

| COA Task 4 concept | Status | Implementation | Source location |
|---|---|---|---|
| Full processor pipeline integration | Implemented | Integrates bin status, route totals, repeated workload, and route summary into one unified CPU execution trace. | [CoaSimulationService.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationService.java#L24-L145) |
| Register & ALU state mapping | Implemented | Real application data mapped to `RAX`, `RBX`, `RCX`, `RDX`, `RSI`, `RDI`, ALU operations, and flags (`ZF`, `SF`, `OF`). | [X64InstructionSimulator.java](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java#L23-L200) |
| Native 64-bit GCC parity | Implemented | Virtual instruction simulation cross-checked against native MinGW GCC assembly binaries; asserting result equality. | [NativeCoaExecutor.java](backend/src/main/java/com/wasteflow/coa/NativeCoaExecutor.java#L35-L110), [native_coa.c](backend/src/main/resources/coa/native/native_coa.c) |
| Native assembly source files | Implemented | Checked-in assembly implementations for bin status, route totals, workloads, and uppercase string parsing. | [bin_status.S](backend/src/main/resources/coa/native/bin_status.S), [route_totals.S](backend/src/main/resources/coa/native/route_totals.S), [route_workload.S](backend/src/main/resources/coa/native/route_workload.S), [route_summary.S](backend/src/main/resources/coa/native/route_summary.S) |
| Unified CO4 API endpoint | Implemented | `POST /api/coa/integrated` runs all processor routines on live data and returns simulated and native traces. | [CoaSimulationController.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationController.java#L35-L55) |
| Demonstration UI & Visualizer | Implemented | Step-by-step instruction visualizer, dual simulated/native engine toggle, and live register inspector. | [AcademicCo4Demo.tsx](frontend/src/AcademicCo4Demo.tsx#L250-L345), [CoaLab.tsx](frontend/src/CoaLab.tsx#L115-L160) |

### Academic Requirement
> "Integrate the COA components developed in the previous tasks into the selected application. Demonstrate the mapping of application-level operations to processor-level operations involving registers, ALU, instructions, control flow and memory/string processing using CPU Simulator and 64-bit Assembly Language."

### Implemented Functionality
1. **Application Data Integration**:
   - Takes actual persisted waste bin fill/capacity levels and active route distances/stops directly from WasteFlow.
   - Converts real physical values to integer milli-units (e.g. 85.00 kg -> 85,000 milli-kg) to match hardware-level integer registers without floating-point emulation errors.
2. **Processor-Level Demonstrations**:
   - **Bin Fill Classification**: Uses `MOV`, `IMUL RAX, 100`, `CQO`, `IDIV RBX`, and `CMP RAX` with conditional jumps (`JGE CRITICAL`, `JGE HIGH`, `JGE MEDIUM`) into output register `RCX`.
   - **Route Distance & Travel Time Totals**: Accumulates multi-leg distance and time using 64-bit `ADD` instructions in `RAX` and `RBX`.
   - **Repeated Route Workload**: Successive addition loop with `ADD RAX, RBX`, `DEC RCX`, and `JNZ REPEAT_ROUTE` demonstrating counter registers and conditional loop branching.
   - **Route Stop Bin-Code String Processing**: Uses `MOV RSI`, `MOV RDI`, string primitives `LODSB` and `STOSB`, null byte delimiters, and byte-level memory buffer formatting.
3. **Hardware Execution vs Educational CPU Simulation**:
   - Compiles checked-in assembly sources ([bin_status.S](backend/src/main/resources/coa/native/bin_status.S), [route_totals.S](backend/src/main/resources/coa/native/route_totals.S), [route_workload.S](backend/src/main/resources/coa/native/route_workload.S), [route_summary.S](backend/src/main/resources/coa/native/route_summary.S)) into a native Windows x86-64 executable via MinGW GCC.
   - Separately traces instruction execution step-by-step through [X64InstructionSimulator.java](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java).
   - Enforces consistency: backend verifies that the native binary result matches the instruction simulation before returning response.
4. **User Interface Integration**:
   - Featured in the dedicated **Academic CO4 Demonstration** view under **3. COA (Processor-Level Integration)** and the standalone **Processor / COA Lab** view.
   - Shows instruction-by-instruction trace, register values (`RAX`, `RBX`, `RCX`, `RDX`, `RSI`, `RDI`), ALU status flags (Zero ZF, Sign SF, Carry CF, Overflow OF), and branching paths.

### Exact Source-Code File Paths
- COA Simulation Service: [CoaSimulationService.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationService.java)
- Native x86-64 Assembler & Executor: [NativeCoaExecutor.java](backend/src/main/java/com/wasteflow/coa/NativeCoaExecutor.java)
- Java Instruction Simulator: [X64InstructionSimulator.java](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java)
- Native Assembly Routines:
  - [bin_status.S](backend/src/main/resources/coa/native/bin_status.S)
  - [route_totals.S](backend/src/main/resources/coa/native/route_totals.S)
  - [route_workload.S](backend/src/main/resources/coa/native/route_workload.S)
  - [route_summary.S](backend/src/main/resources/coa/native/route_summary.S)
- REST Controller: [CoaSimulationController.java](backend/src/main/java/com/wasteflow/coa/CoaSimulationController.java)
- Frontend Demonstration Views: [AcademicCo4Demo.tsx](frontend/src/AcademicCo4Demo.tsx), [CoaLab.tsx](frontend/src/CoaLab.tsx)
- Unit Tests: [CoaSimulationServiceTest.java](backend/src/test/java/com/wasteflow/coa/CoaSimulationServiceTest.java)

### How the Feature Works
1. Operator selects a live waste bin or active collection route.
2. The values are sent via `POST /api/coa/*` endpoints to Spring Boot.
3. [NativeCoaExecutor.java](backend/src/main/java/com/wasteflow/coa/NativeCoaExecutor.java) links with MinGW GCC and executes the 64-bit assembly routine.
4. Concurrently, [X64InstructionSimulator.java](backend/src/main/java/com/wasteflow/coa/X64InstructionSimulator.java) steps through the assembly program, updating simulated registers and calculating CPU condition flags.
5. If the native assembly result and simulator trace register agree, the response is returned with full disassembly and step history.

### Input and Output Examples

**Input (Bin Telemetry):**
- `currentFillKg = 95.0`, `capacityKg = 100.0`
- Register input: `RAX = 95000`, `RBX = 100000`

**Processor Instructions Executed:**
```assembly
MOV RAX, 95000
IMUL RAX, 100
MOV RBX, 100000
CQO
IDIV RBX
CMP RAX, 95
JGE CRITICAL
```

**Output:**
- Final Registers: `RAX = 95`, `RBX = 100000`, `RCX = 3` (Status Code 3 = CRITICAL), `RDX = 0` (Remainder)
- Condition Flags: `ZF = 1` (Zero flag set on CMP), `SF = 0`, `CF = 0`, `OF = 0`
- Result String: `"95% fill -> CRITICAL"`
- Native Verification: `nativeExecutionVerified: true`

### Testing Performed
- `simulatesBinClassificationAtCriticalThreshold`: Tests `IDIV`, `CMP`, conditional jump to `CRITICAL`, and register results.
- `rejectsFillAboveCapacity`: Defensive check throwing `IllegalArgumentException`.
- `simulatesRouteDistanceAndTimeAccumulationWithAddInstructions`: Tests `ADD RAX` and `ADD RBX` on multiple route legs without overflow.
- `estimatesRepeatedRouteDistanceUsingSuccessiveAddition`: Tests successive addition loop with `DEC RCX` and `JNZ`.
- `processesRouteSummaryStringsUsingLodsbAndStosb`: Tests memory string instructions on bin code strings.

### Evidence / Demonstrable Verification
- Open WasteFlow -> Navigate to **Academic CO4** -> Select **3. COA (Processor-Level Integration)**.
- Choose a bin and repetition count -> Click **Run CO4 Processor Mapping**.
- All 4 operations display final registers, status flags, and verified native x86-64 execution status badges. Expand the trace details to inspect every simulated CPU step.

### Conclusion
CO4 for COA is fully integrated and demonstrably active on live application data with genuine native assembly cross-verification.

**Runtime prerequisite:** a 64-bit MinGW GCC toolchain (target `x86_64-w64-mingw32`) must be available. The compiler is selected through `COA_NATIVE_COMPILER` or discovered from PATH/common MSYS2 locations. The Java simulator provides a separate educational trace; it is not presented as a hardware-generated trace.

## Tests

The COA tests compile and execute the native x64 routines, cross-check their outputs against the teaching-simulator trace, and cover bin thresholds, route totals, successive addition, route-summary string processing, and invalid inputs in [CoaSimulationServiceTest.java](backend/src/test/java/com/wasteflow/coa/CoaSimulationServiceTest.java).

## Summary

CO1 processor-model concepts are shown through the teaching-simulator register/flag trace. CO2's bin classification and route totals and CO3's successive-addition and string-processing operations execute as native 64-bit assembly. CO4 integrates them in one COA Lab flow using live WasteFlow data and checks native outputs against the trace. A compatible 64-bit MinGW GCC toolchain is required at runtime.
