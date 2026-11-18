# PSOOP Java Tasks 1, 2, 3, and 4 Implementation

## Project context

WasteFlow is a Java Spring Boot and React application for monitoring waste-bin fill levels, managing collection requests, and planning truck routes. This document maps the PSOOP Java task concepts shown in the assignment sheet to the current implementation.

## Task 1: Java fundamentals

| Concept | Status | How it is used | Source location |
|---|---|---|---|
| Real-world case study | Used | Waste bins, collection requests, trucks, and route planning form the case study. | [WasteBin.java lines 19–55](backend/src/main/java/com/wasteflow/bin/WasteBin.java#L19-L55), [RouteService.java lines 50–115](backend/src/main/java/com/wasteflow/route/RouteService.java#L50-L115) |
| Control statements | Used | Conditions validate bin fill, truck availability/capacity, route state, and search input. | [WasteBin.java lines 75–89](backend/src/main/java/com/wasteflow/bin/WasteBin.java#L75-L89), [Truck.java lines 49–54](backend/src/main/java/com/wasteflow/truck/Truck.java#L49-L54), [RouteService.java lines 50–80](backend/src/main/java/com/wasteflow/route/RouteService.java#L50-L80) |
| Loops | Used | Loops search bins and process selected requests, roads, and route stops. | [WasteBinService.java lines 44–60](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L44-L60), [RouteService.java lines 66–94](backend/src/main/java/com/wasteflow/route/RouteService.java#L66-L94), [RouteService.java lines 104–115](backend/src/main/java/com/wasteflow/route/RouteService.java#L104-L115) |
| Array | Used | Repository results are converted into a `WasteBinResponse[]`; the array is traversed for linear search and returned for listing. | [WasteBinService.java lines 44–60](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L44-L60) |
| `StringBuilder` | Used | Builds a readable route report containing truck, ordered bin stops, distance, and time. | [RouteResponse.java lines 19–39](backend/src/main/java/com/wasteflow/route/dto/RouteResponse.java#L19-L39) |
| `StringBuffer` | Not used | No `StringBuffer` use exists in the application Java source. The route summary is local to a request, so a synchronized shared buffer is not needed. | — |
| Objects and classes | Used | Domain classes represent bins, trucks, routes, and other application objects. | [WasteBin.java lines 19–55](backend/src/main/java/com/wasteflow/bin/WasteBin.java#L19-L55), [Truck.java lines 16–41](backend/src/main/java/com/wasteflow/truck/Truck.java#L16-L41) |
| Methods | Used | Domain methods perform operations such as updating/classifying a bin and assigning a truck. | [WasteBin.java lines 67–99](backend/src/main/java/com/wasteflow/bin/WasteBin.java#L67-L99), [Truck.java lines 49–61](backend/src/main/java/com/wasteflow/truck/Truck.java#L49-L61) |

### Array and CRUD distinction

Bin listing and linear search use an array in memory. Create, update, and delete are application features, but their persistent storage is the database through Spring Data JPA rather than the array.

- Search/list: [WasteBinService.java lines 44–60](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L44-L60)
- Create: [WasteBinService.java lines 124–134](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L124-L134)
- Update: [WasteBinService.java lines 136–142](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L136-L142)
- Delete: [WasteBinService.java lines 145–150](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L145-L150)

## Task 2: OOP, Java features, and programming pattern

| Concept | Status | How it is used | Source location |
|---|---|---|---|
| Lambda expressions | Used | Lambdas transform/select route strategies and process requests; the nearest-stop strategy compares candidate distances. | [RouteService.java lines 45–46](backend/src/main/java/com/wasteflow/route/RouteService.java#L45-L46), [RouteService.java lines 62–64](backend/src/main/java/com/wasteflow/route/RouteService.java#L62-L64), [NearestStopRouteStrategy.java lines 32–48](backend/src/main/java/com/wasteflow/route/NearestStopRouteStrategy.java#L32-L48) |
| Interface | Used | Defines the contract shared by route-ordering algorithms. | [RouteRequestOrderingStrategy.java lines 8–14](backend/src/main/java/com/wasteflow/route/RouteRequestOrderingStrategy.java#L8-L14) |
| Abstract class | Used | Provides shared path-finder state and priority-ordering behavior for route strategies. | [AbstractRouteRequestOrderingStrategy.java lines 10–22](backend/src/main/java/com/wasteflow/route/AbstractRouteRequestOrderingStrategy.java#L10-L22) |
| Inheritance | Used | Priority-first and nearest-stop strategy classes extend the shared abstract strategy. | [PriorityFirstRouteStrategy.java lines 11–12](backend/src/main/java/com/wasteflow/route/PriorityFirstRouteStrategy.java#L11-L12), [NearestStopRouteStrategy.java lines 12–13](backend/src/main/java/com/wasteflow/route/NearestStopRouteStrategy.java#L12-L13) |
| Polymorphism | Used | `RouteService` looks up a strategy by algorithm name and calls its interface method; the selected implementation determines request order. | [RouteService.java lines 50–53](backend/src/main/java/com/wasteflow/route/RouteService.java#L50-L53), [RouteService.java lines 85–86](backend/src/main/java/com/wasteflow/route/RouteService.java#L85-L86) |
| `static` keyword | Used | The application entry point and response factory methods are static. | [BackendApplication.java lines 9–13](backend/src/main/java/com/wasteflow/BackendApplication.java#L9-L13), [RouteResponse.java lines 19–40](backend/src/main/java/com/wasteflow/route/dto/RouteResponse.java#L19-L40) |
| `final` keyword | Used | Service dependencies are final fields; the custom linked-list class is final. | [RouteService.java lines 28–35](backend/src/main/java/com/wasteflow/route/RouteService.java#L28-L35), [SinglyLinkedList.java lines 10–14](backend/src/main/java/com/wasteflow/route/SinglyLinkedList.java#L10-L14) |
| `super` keyword | Used | Each concrete route-strategy constructor initializes the shared superclass with `super(...)`. | [PriorityFirstRouteStrategy.java lines 11–15](backend/src/main/java/com/wasteflow/route/PriorityFirstRouteStrategy.java#L11-L15), [NearestStopRouteStrategy.java lines 12–16](backend/src/main/java/com/wasteflow/route/NearestStopRouteStrategy.java#L12-L16) |
| Exception handling | Used | Business rules throw argument/state exceptions; a global handler converts them into HTTP error responses. | [RouteService.java lines 50–60](backend/src/main/java/com/wasteflow/route/RouteService.java#L50-L60), [GlobalExceptionHandler.java lines 13–34](backend/src/main/java/com/wasteflow/common/GlobalExceptionHandler.java#L13-L34) |
| Java packages | Used | Code is organized into packages such as `bin`, `route`, `truck`, and `simulation`. | [WasteBin.java package declaration](backend/src/main/java/com/wasteflow/bin/WasteBin.java#L1), [RouteService.java package declaration](backend/src/main/java/com/wasteflow/route/RouteService.java#L1), [Truck.java package declaration](backend/src/main/java/com/wasteflow/truck/Truck.java#L1) |
| Java collections | Used | `List`, `Map`, `Optional`, and collection operations manage requests, graph data, and strategies. | [RouteService.java lines 35–46](backend/src/main/java/com/wasteflow/route/RouteService.java#L35-L46), [RouteService.java lines 61–115](backend/src/main/java/com/wasteflow/route/RouteService.java#L61-L115), [WeightedGraph.java lines 10–18](backend/src/main/java/com/wasteflow/route/algorithm/WeightedGraph.java#L10-L18) |
| Java generics | Used | The custom linked list is generic (`SinglyLinkedList<T>`) and is used for collection requests and route stops. | [SinglyLinkedList.java lines 10–14](backend/src/main/java/com/wasteflow/route/SinglyLinkedList.java#L10-L14), [RouteService.java lines 61–70](backend/src/main/java/com/wasteflow/route/RouteService.java#L61-L70), [RouteService.java lines 100–115](backend/src/main/java/com/wasteflow/route/RouteService.java#L100-L115) |
| Java Swing | Used | A standalone desktop operations client displays bins, pending requests, available trucks, and route stops, and lets an operator plan, start, undo, and complete route work. | [WasteFlowDesktop.java lines 30–73](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L30-L73), [WasteFlowDesktop.java lines 77–106](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L77-L106), [WasteFlowDesktop.java lines 242–279](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L242-L279), [WasteFlowDesktop.java lines 282–333](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L282-L333) |
| Programming pattern | Used | The Strategy Pattern provides selectable priority-first and nearest-stop route ordering. | [RouteRequestOrderingStrategy.java lines 8–14](backend/src/main/java/com/wasteflow/route/RouteRequestOrderingStrategy.java#L8-L14), [RouteService.java lines 45–53](backend/src/main/java/com/wasteflow/route/RouteService.java#L45-L53), [RouteService.java lines 85–86](backend/src/main/java/com/wasteflow/route/RouteService.java#L85-L86) |

## Task 3: Exception handling, Java Swing, packages, and collections

### Concepts and locations

| Task 3 concept | How it is used | Source location |
|---|---|---|
| Exception handling in application rules | Invalid input and invalid state transitions throw clear Java exceptions; the REST advice maps them to structured HTTP 400/409 error responses. | [RouteService.java lines 50–60](backend/src/main/java/com/wasteflow/route/RouteService.java#L50-L60), [GlobalExceptionHandler.java lines 13–34](backend/src/main/java/com/wasteflow/common/GlobalExceptionHandler.java#L13-L34), [ApiError.java lines 6–9](backend/src/main/java/com/wasteflow/common/ApiError.java#L6-L9) |
| Exception handling in the desktop app | API/network failures from background Swing tasks are caught and shown to the operator; interrupted tasks restore the thread's interrupt flag. | [WasteFlowDesktop.java lines 335–361](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L335-L361), [WasteFlowApiClient.java lines 80–132](desktop/src/main/java/com/wasteflow/desktop/WasteFlowApiClient.java#L80-L132) |
| Java Swing GUI | The standalone operator client displays bin, request, truck, and route-stop tables and offers controls to plan, start, undo, and complete routes. | [WasteFlowDesktop.java lines 30–73](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L30-L73), [WasteFlowDesktop.java lines 77–106](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L77-L106), [WasteFlowDesktop.java lines 242–279](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L242-L279), [WasteFlowDesktop.java lines 282–333](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L282-L333), [README.md](desktop/README.md) |
| Java packages | Classes are grouped by domain and layer, including `bin`, `route`, `collection`, `truck`, `coa`, `common`, and `desktop`. | [WasteBin.java package declaration](backend/src/main/java/com/wasteflow/bin/WasteBin.java#L1), [RouteService.java package declaration](backend/src/main/java/com/wasteflow/route/RouteService.java#L1), [Truck.java package declaration](backend/src/main/java/com/wasteflow/truck/Truck.java#L1), [WasteFlowDesktop.java package declaration](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L1) |
| Java collections | `List` holds requests, trucks, bins, and route stops; `Map` stores graph adjacency, strategy lookup, and error field details. | [WasteFlowDesktop.java lines 55–56](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L55-L56), [WasteFlowDesktop.java lines 234–279](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L234-L279), [RouteService.java lines 35–46](backend/src/main/java/com/wasteflow/route/RouteService.java#L35-L46), [WeightedGraph.java lines 10–18](backend/src/main/java/com/wasteflow/route/algorithm/WeightedGraph.java#L10-L18), [ApiError.java lines 6–9](backend/src/main/java/com/wasteflow/common/ApiError.java#L6-L9) |
| Live case-study integration | The Swing client uses the existing REST backend; undoing an unstarted route returns its requests to pending and frees its truck. | [WasteFlowDesktop.java lines 97–101](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L97-L101), [WasteFlowApiClient.java lines 34–67](desktop/src/main/java/com/wasteflow/desktop/WasteFlowApiClient.java#L34-L67), [RouteService.java lines 120–137](backend/src/main/java/com/wasteflow/route/RouteService.java#L120-L137) |

### Task 3 workflow

1. Start the WasteFlow backend and launch the Swing desktop client ([WasteFlowDesktop.java lines 64–73](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L64-L73)).
2. Select pending requests, an available truck, and a route-ordering algorithm to plan a collection route ([WasteFlowDesktop.java lines 282–299](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L282-L299)).
3. Before dispatch, use **Undo latest plan** to cancel the newest unstarted route and return its requests to pending status ([WasteFlowDesktop.java lines 97–101](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L97-L101), [RouteService.java lines 120–137](backend/src/main/java/com/wasteflow/route/RouteService.java#L120-L137)).
4. Start the route and complete its stops. Invalid operations and API failures are surfaced through structured backend responses or desktop error dialogs ([WasteFlowDesktop.java lines 300–333](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L300-L333), [WasteFlowDesktop.java lines 335–361](desktop/src/main/java/com/wasteflow/desktop/WasteFlowDesktop.java#L335-L361), [GlobalExceptionHandler.java lines 13–34](backend/src/main/java/com/wasteflow/common/GlobalExceptionHandler.java#L13-L34)).

## Task 4 (CO4): File Handling and Generics

### Concepts and locations

| Task 4 concept | Status | How it is used | Source location |
|---|---|---|---|
| Reusable generic CSV engine | Implemented | `CsvFileWriter<T>` handles arbitrary entity types `T` via higher-order generic functional mappers without raw types. | [CsvFileWriter.java](backend/src/main/java/com/wasteflow/report/CsvFileWriter.java#L19-L85) |
| RFC-4180 escaping & UTF-8 | Implemented | Full compliance with standard delimiter quoting, quote doubling (`""`), CRLF line endings, and UTF-8 encoding. | [CsvFileWriter.java](backend/src/main/java/com/wasteflow/report/CsvFileWriter.java#L87-L135) |
| Temporary file safe lifecycle | Implemented | `writeToBytes()` writes to an OS temp file, streams bytes, and guarantees removal in `finally { Files.deleteIfExists(tempFile); }`. | [CsvFileWriter.java](backend/src/main/java/com/wasteflow/report/CsvFileWriter.java#L40-L65) |
| Bidirectional file I/O | Implemented | Supports both streaming creation and parsing verification via `read(Path)` and `readFromBytes(byte[])`. | [CsvFileWriter.java](backend/src/main/java/com/wasteflow/report/CsvFileWriter.java#L67-L115) |
| Multi-entity generic export | Implemented | Type-safe generic export across route reports, waste bins, fleet vehicles, and collection requests. | [DataExportService.java](backend/src/main/java/com/wasteflow/report/DataExportService.java#L25-L105) |
| Export REST endpoints | Implemented | Endpoints streaming CSV files with proper MIME types, Content-Disposition headers, and verification API. | [DataExportController.java](backend/src/main/java/com/wasteflow/report/DataExportController.java#L20-L65) |
| Operator export UI | Implemented | Easily accessible export buttons on Route Planner, Reports panel, and dedicated CO4 demonstration cards. | [ReportsPanel.tsx](frontend/src/ReportsPanel.tsx#L18-L95), [AcademicCo4Demo.tsx](frontend/src/AcademicCo4Demo.tsx#L170-L245) |

### Academic Requirement
> "Utilize logic building traits efficiently for solving real-life problems: Use file handling and Java generics for the proper execution of the given case study."

### Implemented Functionality
1. **Generic CSV File Engine (`CsvFileWriter<T>`)**:
   - Reusable across any entity type `T` via higher-order generic functional interface `Function<? super T, ? extends List<String>>`.
   - Used for 4 distinct domain entity classes without raw types or casting:
     - Route collection reports (`RouteReportRow`)
     - Waste bins asset register (`WasteBin`)
     - Collection fleet trucks (`Truck`)
     - Citizen and automated collection requests (`CollectionRequest`)
2. **Reliable Java File Handling**:
   - Creates temporary files via `Files.createTempFile("wasteflow-export-", ".csv")`.
   - Buffered streaming writing using `BufferedWriter` with strict `StandardCharsets.UTF_8` encoding.
   - Robust RFC-4180 escaping: cells with commas, quotes, CRLF, or LF are quoted; embedded double quotes are escaped as `""`.
   - Full read support with `read(Path)` and `readFromBytes(byte[])`, validating header structure and row dimensions.
   - Guaranteed cleanup: temporary files are deleted in a `try ... finally` block, ensuring no leftover disk storage even when an I/O error or serialization exception occurs.
3. **Application Integration & Operator Station**:
   - Live endpoints for CSV downloads:
     - `GET /api/routes/{routeId}/report.csv` and `GET /api/reports/routes/{routeId}.csv`
     - `GET /api/reports/bins.csv`
     - `GET /api/reports/trucks.csv`
     - `GET /api/reports/requests.csv`
     - `POST /api/reports/verify` (round-trip file read back and validation)
   - Integrated into both Route Planner and the **Academic CO4 Demonstration** dashboard view with live download progress and success/failure alerts.

### Exact Source-Code File Paths
- Generic Writer & Reader: [CsvFileWriter.java](backend/src/main/java/com/wasteflow/report/CsvFileWriter.java)
- Route Report Service: [RouteReportService.java](backend/src/main/java/com/wasteflow/report/RouteReportService.java)
- Multi-Entity Export Service: [DataExportService.java](backend/src/main/java/com/wasteflow/report/DataExportService.java)
- REST Export Controller: [DataExportController.java](backend/src/main/java/com/wasteflow/report/DataExportController.java)
- Route Report Controller: [RouteReportController.java](backend/src/main/java/com/wasteflow/report/RouteReportController.java)
- Frontend API Integration: [api.ts](frontend/src/api.ts)
- Academic CO4 Dashboard UI: [AcademicCo4Demo.tsx](frontend/src/AcademicCo4Demo.tsx)
- Unit Tests: [CsvFileWriterTest.java](backend/src/test/java/com/wasteflow/report/CsvFileWriterTest.java), [DataExportServiceTest.java](backend/src/test/java/com/wasteflow/report/DataExportServiceTest.java)

### How the Feature Works
1. Operator requests an export (e.g., Waste Bins or Route Report).
2. The service queries JPA repository data from the MySQL database.
3. The generic `CsvFileWriter<T>.writeToBytes()` creates a temporary file on the host filesystem.
4. It streams out headers followed by each object mapped to column strings using lambda expressions (e.g. `bin -> Arrays.asList(...)`).
5. All bytes are read into memory for HTTP download transmission.
6. A `finally` block executes `Files.deleteIfExists(tempFile)`, guaranteeing immediate cleanup.
7. The operator's browser receives the file with `Content-Type: text/csv; charset=UTF-8` and `Content-Disposition: attachment`.

### Input and Output Examples

**Input (Database Entity):**
- WasteBin `[id=1, binCode="BIN-001", location="North Gate", capacity=100.0, fill=85.0, status=HIGH, wasteType=GENERAL]`

**Output (Generated UTF-8 CSV Row):**
```csv
id,binCode,locationName,capacityKg,currentFillKg,fillPercentage,wasteType,status
1,BIN-001,North Gate,100.00,85.00,85.0,GENERAL,HIGH
```

**Special Character & RFC-4180 Escaping Example:**
- Input: `location="North, Zone #1"`, `note="Needs \"urgent\" pickup\nCall supervisor"`
- Output: `"North, Zone #1","Needs ""urgent"" pickup\nCall supervisor"`

### Testing Performed
- `CsvFileWriterTest.writesGenericRowsAsUtf8CsvAndEscapesSpecialCells`: Verifies UTF-8 and quoting.
- `CsvFileWriterTest.writesEmptyReportWithOnlyHeaders`: Handles empty datasets gracefully.
- `CsvFileWriterTest.writesAndReadsBackMultipleRecordsWithUtf8SpecialCharacters`: Full round-trip read/write verification.
- `CsvFileWriterTest.writeToBytesGeneratesByteOutputAndCleansUpTempFiles`: Ensures temporary file creation and cleanup.
- `CsvFileWriterTest.rejectsNullOrEmptyArguments`: Defensive error handling.
- `DataExportServiceTest.exportsBinsToValidUtf8Csv`: Verifies bin entity export.
- `DataExportServiceTest.exportsTrucksToValidUtf8Csv`: Verifies truck entity export.
- `DataExportServiceTest.exportsCollectionRequestsToValidUtf8Csv`: Verifies request entity export.
- `DataExportServiceTest.handlesVerificationOfInvalidAndEmptyCsv`: Verifies file reader validation.

### Evidence / Demonstrable Verification
- **Frontend Demonstration**: Open "Academic CO4" tab in WasteFlow sidebar -> Select "2. PSOOP (File Handling & Generics)" -> Click "Export Bins CSV", "Export Trucks CSV", or "Export Route CSV" -> File downloads immediately with row count banner.
- **Verification Button**: Click "Verify CSV File Read & Parse" to demonstrate backend `read()` parsing the file back and reporting verified record counts.

### Conclusion
CO4 for PSOOP is fully achieved. Java file handling and Java generics are deeply integrated into real-world waste management reporting, providing type-safe, reusable, reliable, and clean file operations.

## Summary

Task 1 uses control statements, loops, arrays, `StringBuilder`, objects, and methods. `StringBuffer` is not used. Task 2 uses lambdas, an interface, an abstract class, inheritance, polymorphism, `static`, `final`, `super`, generics, and the Strategy Pattern. Task 3's exception handling, Java Swing client, domain packages, and Java collections are integrated with WasteFlow's live bin and route workflows. Task 4 applies generic Java file handling to downloadable route reports while keeping persisted route data in the database.
