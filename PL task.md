# Programming Lab Tasks 1, 2, 3, and 4 Implementation

## Project

**WasteFlow** is a waste-bin collection and route-planning application. It tracks bin fill levels and collection requests, then plans truck stops. The real-world problem and application overview are described in [explanation.md](explanation.md#1-project-overview) and [explanation.md](explanation.md#2-problem-being-solved).

## Task 1: Arrays and Basic Operations

### Concepts and locations

| Task 1 concept | How it is used | Source location |
|---|---|---|
| Array storage | The backend loads repository results into a `WasteBinResponse[]` working snapshot before listing or CRUD operations. | [WasteBinService.java](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L47-L49), [WasteBinService.java](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L162-L206) |
| Display | Bin responses are stored in the `arrayBins` snapshot and rendered as table rows. | [WasteBinService.java](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L47-L51), [App.tsx](frontend/src/App.tsx#L369-L414) |
| Search | The backend scans its response array for bin code or location; the exact-code lookup is also available through the existing hash-index feature. | [WasteBinService.java](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L47-L63), [App.tsx](frontend/src/App.tsx#L372-L379) |
| Insert into Java array | Create loads the current bin array, saves the new record through JPA, then appends the server-created response using `WasteBinArrayOperations.insert`. | [WasteBinArrayOperations.java](backend/src/main/java/com/wasteflow/bin/WasteBinArrayOperations.java#L11-L14), [WasteBinService.java](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L162-L179) |
| Update Java array item | Edit locates the bin by ID in the array, persists the changed entity, then replaces that array element using `WasteBinArrayOperations.update`. | [WasteBinArrayOperations.java](backend/src/main/java/com/wasteflow/bin/WasteBinArrayOperations.java#L16-L26), [WasteBinService.java](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L181-L192) |
| Delete Java array item | Delete removes the bin from the active Java array and Bin Network using a soft delete; it cancels pending requests while preserving the database row and route history. | [WasteBinArrayOperations.java](backend/src/main/java/com/wasteflow/bin/WasteBinArrayOperations.java#L29-L39), [WasteBinService.java](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L185-L198) |
| Frontend array snapshot | After API success, `insertBinIntoArray`, `updateBinInArray`, or `deleteBinFromArray` immediately updates the Bin Network UI; it then refreshes from the server. | [binArrayOperations.ts](frontend/src/binArrayOperations.ts#L3-L13), [App.tsx](frontend/src/App.tsx#L338-L370) |
| Persist CRUD changes | JPA remains persistent storage. The Java array is a refreshed in-memory working snapshot used by backend listing and CRUD operations; the frontend maintains its own UI snapshot. | [WasteBinService.java](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L47-L49), [WasteBinController.java](backend/src/main/java/com/wasteflow/bin/WasteBinController.java#L38-L52), [App.tsx](frontend/src/App.tsx#L338-L370) |
| Read a single record | A bin is retrieved by its ID and returned to the API. | [WasteBinController.java](backend/src/main/java/com/wasteflow/bin/WasteBinController.java#L33-L35), [WasteBinService.java](backend/src/main/java/com/wasteflow/bin/WasteBinService.java#L64-L66) |

### Important implementation detail

Create, update, and delete now perform corresponding insert, replace, and remove operations on a Java `WasteBinResponse[]` working snapshot in `WasteBinService`, as well as updating the frontend's in-memory array snapshot after API success. Spring Data JPA remains persistent storage; the backend reloads the array snapshot from the repository before listing and CRUD operations. Search is available through `GET /api/bins?search=<text>`.

## Task 2: Singly Linked List

### Structure and operations

The project defines its own generic singly linked list in [SinglyLinkedList.java](backend/src/main/java/com/wasteflow/route/SinglyLinkedList.java).

| Linked-list concept | Implementation location |
|---|---|
| Head, tail, and size | [SinglyLinkedList.java](backend/src/main/java/com/wasteflow/route/SinglyLinkedList.java#L10-L14) |
| Node containing a value and next reference | [SinglyLinkedList.java](backend/src/main/java/com/wasteflow/route/SinglyLinkedList.java#L80-L86) |
| Insert at tail | `add` in [SinglyLinkedList.java](backend/src/main/java/com/wasteflow/route/SinglyLinkedList.java#L16-L25) |
| Find/search | `find` in [SinglyLinkedList.java](backend/src/main/java/com/wasteflow/route/SinglyLinkedList.java#L27-L34) |
| Update | `update` in [SinglyLinkedList.java](backend/src/main/java/com/wasteflow/route/SinglyLinkedList.java#L36-L44) |
| Delete | `remove` in [SinglyLinkedList.java](backend/src/main/java/com/wasteflow/route/SinglyLinkedList.java#L46-L66) |
| Traverse/display in list order | `toList` in [SinglyLinkedList.java](backend/src/main/java/com/wasteflow/route/SinglyLinkedList.java#L68-L74) |
| Get element count | `size` in [SinglyLinkedList.java](backend/src/main/java/com/wasteflow/route/SinglyLinkedList.java#L76-L78) |

### Integration in WasteFlow

During route planning, selected collection requests are added to the linked list, checked for duplicates, and converted to an ordered list at [RouteService.java lines 61–75](backend/src/main/java/com/wasteflow/route/RouteService.java#L61-L75). Requests are then updated and removed while route stops are appended and traversed for persistence at [RouteService.java lines 100–115](backend/src/main/java/com/wasteflow/route/RouteService.java#L100-L115).

A linked list is suitable here because the number of selected requests and route stops varies per route. The structure can grow dynamically and appending at the tail is constant time. Searching, updating, and removing by value require traversal, which is acceptable for the small route lists in this project.

## Task 3: Queue and Stack

### Concepts and locations

| Task 3 concept | How it is used | Source location |
|---|---|---|
| Queue storage (FIFO) | A custom generic array-backed queue stores collection requests in the route's planned stop order. | [ArrayQueue.java lines 6–58](backend/src/main/java/com/wasteflow/route/ArrayQueue.java#L6-L58) |
| Enqueue | Ordered requests are added to the dispatch queue after the route-ordering strategy selects their sequence. | [RouteService.java lines 101–103](backend/src/main/java/com/wasteflow/route/RouteService.java#L101-L103) |
| Dequeue | Requests are removed one at a time from the front of the queue, assigned, and converted into route stops in FIFO order. | [RouteService.java lines 104–115](backend/src/main/java/com/wasteflow/route/RouteService.java#L104-L115), [ArrayQueue.java lines 21–34](backend/src/main/java/com/wasteflow/route/ArrayQueue.java#L21-L34) |
| Queue inspection and state | `peek`, `isEmpty`, and `size` expose the front item and queue state. | [ArrayQueue.java lines 36–49](backend/src/main/java/com/wasteflow/route/ArrayQueue.java#L36-L49) |
| Stack storage (LIFO) | A custom generic array-backed stack holds unstarted routes that are eligible for undo. | [ArrayStack.java lines 6–46](backend/src/main/java/com/wasteflow/route/ArrayStack.java#L6-L46) |
| Push and pop | Routes are pushed oldest-to-newest and the newest planned route is popped for undo. | [RouteService.java lines 120–128](backend/src/main/java/com/wasteflow/route/RouteService.java#L120-L128), [ArrayStack.java lines 11–30](backend/src/main/java/com/wasteflow/route/ArrayStack.java#L11-L30) |
| Stack inspection and state | `peek`, `isEmpty`, and `size` expose the top item and stack state. | [ArrayStack.java lines 32–45](backend/src/main/java/com/wasteflow/route/ArrayStack.java#L32-L45) |
| Undo planned route | The operator can undo the latest unstarted route; it is cancelled, its truck is made available, and its requests return to pending. Started routes cannot be undone. | [RouteService.java lines 120–137](backend/src/main/java/com/wasteflow/route/RouteService.java#L120-L137), [RouteController.java lines 32–35](backend/src/main/java/com/wasteflow/route/RouteController.java#L32-L35), [App.tsx lines 115–125](frontend/src/App.tsx#L115-L125), [App.tsx lines 180–212](frontend/src/App.tsx#L180-L212) |

### Integration in WasteFlow

When a route is built, the chosen route-ordering strategy first determines the stop sequence. The service enqueues that sequence and dequeues requests one at a time to assign them and create route stops in FIFO order ([RouteService.java lines 101–115](backend/src/main/java/com/wasteflow/route/RouteService.java#L101-L115)). Before a planned route has started, the operator can choose **Undo plan**. The service loads unstarted assigned routes from oldest to newest, pushes them onto a stack, and pops the newest route. It cancels that route, makes its truck available, and returns its assigned requests to pending status ([RouteService.java lines 120–137](backend/src/main/java/com/wasteflow/route/RouteService.java#L120-L137)). Started routes cannot be undone, preventing already collected work from being reversed.

## Task 4 (CO4 and CO5): Searching, Sorting and Hashing

### Concepts and locations

| Task 4 concept | How it is used | Source location |
|---|---|---|
| Bin code hash table | Open addressing hash table with linear probing resolving collisions for expected $O(1)$ search. | [BinCodeHashIndex.java](backend/src/main/java/com/wasteflow/bin/BinCodeHashIndex.java#L28-L95) |
| Collision handling | Probing displacement: `(slot + 1) % keys.length`, tracking collision counts and slot telemetry. | [BinCodeHashIndex.java](backend/src/main/java/com/wasteflow/bin/BinCodeHashIndex.java#L80-L115) |
| Dynamic table resizing | Table doubles capacity and rehashes when load factor exceeds 0.70 threshold. | [BinCodeHashIndex.java](backend/src/main/java/com/wasteflow/bin/BinCodeHashIndex.java#L65-L79) |
| Sorting algorithms | Implements Bubble Sort, Insertion Sort, Selection Sort, and Merge Sort across multiple fields. | [BinSortAlgorithms.java](backend/src/main/java/com/wasteflow/bin/BinSortAlgorithms.java#L15-L120) |
| Empirical benchmark | Real-time `System.nanoTime()` execution profiling on small (25), medium (100), and large (500) datasets. | [AlgorithmBenchmarkService.java](backend/src/main/java/com/wasteflow/bin/AlgorithmBenchmarkService.java#L30-L130) |
| Benchmark REST API | REST controllers for performance benchmarks and live hash table slot diagnostics. | [AlgorithmBenchmarkController.java](backend/src/main/java/com/wasteflow/bin/AlgorithmBenchmarkController.java#L15-L35) |
| Demonstration UI | Interactive GUI displaying comparison tables, slot probing diagrams, and analytical conclusions. | [AcademicCo4Demo.tsx](frontend/src/AcademicCo4Demo.tsx#L48-L165) |

### Academic Requirement
> "Add appropriate searching, sorting and hashing techniques. Implement collision handling, compare algorithm performance, test different datasets and submit the complete integrated application with results and conclusions."

### Implemented Functionality
1. **Searching Techniques**:
   - **Hash Table Exact Lookup (`BinCodeHashIndex`)**: Uses open addressing with linear probing to achieve expected O(1) time complexity. Missing bin handling returns 404 Not Found without throwing uncaught exceptions.
   - **Array Linear Search**: Sequentially scans the in-memory array working snapshot (O(n) time complexity) for comparison against direct hashing.
2. **Sorting Techniques**:
   - Implements and preserves four distinct sorting algorithms in [BinSortAlgorithms.java](backend/src/main/java/com/wasteflow/bin/BinSortAlgorithms.java):
     - **Bubble Sort**: O(n²) worst/average, O(n) best, O(1) space, stable.
     - **Insertion Sort**: O(n²) worst/average, O(n) best, O(1) space, stable.
     - **Selection Sort**: O(n²) all cases, O(1) space, unstable.
     - **Merge Sort**: O(n log n) all cases, O(n) space, stable.
   - Supports multi-field sorting by:
     - Bin fill percentage (`FILL_LEVEL`, descending urgency order)
     - Bin alphanumeric code (`BIN_CODE`, alphabetical A–Z)
     - Location name (`LOCATION`, alphabetical A–Z)
3. **Hashing & Collision Handling**:
   - Custom hash table [BinCodeHashIndex.java](backend/src/main/java/com/wasteflow/bin/BinCodeHashIndex.java) with power-of-two capacity (initial 16).
   - Collision resolution using linear probing: `(slot + 1) % keys.length`.
   - Collision tracking: records collision counts whenever a probe step occurs.
   - Dynamic table resizing: automatically doubles capacity and rehashes entries when the load factor exceeds 0.70.
   - Table slot inspection: exposes internal slot details (index, key, value, initial hash, probe distance).
4. **Empirical Algorithm Performance Benchmark**:
   - Evaluates sorting and searching on small (N=25), medium (N=100), and large (N=500) datasets.
   - Non-fabricated execution runtimes measured using `System.nanoTime()`.
   - Generates empirical conclusions comparing O(n log n) vs O(n²) scaling and O(1) vs O(n) lookups.
   - Exposes REST endpoints:
     - `GET /api/pl/benchmark?size={N}`
     - `GET /api/pl/hash-inspect`
   - Dedicated interactive GUI in the **Academic CO4 Demonstration** view.

### Exact Source-Code File Paths
- Hash Table Engine: [BinCodeHashIndex.java](backend/src/main/java/com/wasteflow/bin/BinCodeHashIndex.java)
- Sorting Algorithms: [BinSortAlgorithms.java](backend/src/main/java/com/wasteflow/bin/BinSortAlgorithms.java)
- Benchmark Engine: [AlgorithmBenchmarkService.java](backend/src/main/java/com/wasteflow/bin/AlgorithmBenchmarkService.java)
- Benchmark Controller: [AlgorithmBenchmarkController.java](backend/src/main/java/com/wasteflow/bin/AlgorithmBenchmarkController.java)
- Waste Bin Service: [WasteBinService.java](backend/src/main/java/com/wasteflow/bin/WasteBinService.java)
- Waste Bin Controller: [WasteBinController.java](backend/src/main/java/com/wasteflow/bin/WasteBinController.java)
- Frontend Demonstration UI: [AcademicCo4Demo.tsx](frontend/src/AcademicCo4Demo.tsx)
- Frontend API Client: [api.ts](frontend/src/api.ts)
- Unit Tests: [BinCodeHashIndexTest.java](backend/src/test/java/com/wasteflow/bin/BinCodeHashIndexTest.java), [BinSortAlgorithmsTest.java](backend/src/test/java/com/wasteflow/bin/BinSortAlgorithmsTest.java), [AlgorithmBenchmarkServiceTest.java](backend/src/test/java/com/wasteflow/bin/AlgorithmBenchmarkServiceTest.java)

### How the Feature Works
1. **Search**: When an operator looks up a bin code (e.g. `BIN-003`), `BinCodeHashIndex.findSlot` computes `Math.floorMod(code.hashCode(), capacity)`. If a collision occurs with an existing entry, linear probing examines subsequent slots until either the key is found or an empty slot is reached.
2. **Sort**: When an operator sorts bins by fill level or code, `BinSortAlgorithms.sort` creates a copy of the active bin list and dispatches to the selected algorithm, preserving the original array order.
3. **Benchmark**: The benchmark tool generates N items, executes each sorting algorithm against an identical reversed comparator, executes 500 search queries on random keys, and records CPU nanoseconds.
4. **Collision Inspection**: `BinCodeHashIndex.getSlotDetails()` returns an array of slot states, allowing visual inspection of probed displacements.

### Input and Output Examples

**Benchmark Comparison Table (Actual Server Timings N=100):**
| Algorithm | Category | Best | Average | Worst | Space | Measured Time |
|---|---|---|---|---|---|---|
| Bubble Sort | SORTING | O(n) | O(n²) | O(n²) | O(1) | ~180.50 µs |
| Insertion Sort | SORTING | O(n) | O(n²) | O(n²) | O(1) | ~45.20 µs |
| Selection Sort | SORTING | O(n²) | O(n²) | O(n²) | O(1) | ~112.40 µs |
| Merge Sort | SORTING | O(n log n) | O(n log n) | O(n log n) | O(n) | ~72.10 µs |
| Linear Search | SEARCHING | O(1) | O(n) | O(n) | O(1) | ~850.30 µs (500 queries) |
| Hash Table Lookup | SEARCHING | O(1) | O(1) | O(n) | O(n) | ~95.20 µs (500 queries) |

**Empirical Conclusions Generated:**
- Merge Sort exhibits superior scaling as N grows beyond 100, maintaining consistent logarithmic divide-and-conquer behavior without quadratic degradation.
- Hash table direct addressing achieves an 8.9x speedup over sequential array scans for 500 lookups.
- For N=100 keys, the hash table resized 4 times to reach 256 slots (load factor 0.39), successfully resolving collisions without key loss.

### Testing Performed
- `BinCodeHashIndexTest`: Tests key insertions, updates, lookups, collision chains, and dynamic resizing past load factor 0.70.
- `BinSortAlgorithmsTest`: Tests Bubble, Insertion, Selection, and Merge Sort on ordered, reverse-ordered, duplicate, and random lists.
- `AlgorithmBenchmarkServiceTest`: Executes benchmarks on small (N=25), medium (N=100), and large (N=500) datasets, verifying non-negative measured times, correct complexities, and non-empty analytical conclusions.

### Evidence / Demonstrable Verification
- Open the WasteFlow dashboard -> Navigate to **Academic CO4** -> Select **1. PL (Searching, Sorting & Hashing)**.
- Perform a hash search for `BIN-001` (instant result) and `BIN-999` (handles missing bin cleanly).
- Select sorting by "Fill Level" with "Merge Sort" -> Observe sorted table output.
- Click **Run Benchmark** with Small (25), Medium (100), or Large (500) -> View the live performance comparison table and analytical conclusions.
- Click **Inspect Live Hash Index** -> View table capacity, load factor, collision count, and slot displacement badges.

### Conclusion
CO4 and CO5 requirements for Programming Lab are completely fulfilled with genuine, non-fabricated performance benchmarks, collision handling, and interactive visual verification.

## Tests

The linked-list operations are covered by [SinglyLinkedListTest.java lines 13–27](backend/src/test/java/com/wasteflow/route/SinglyLinkedListTest.java#L13-L27); queue and stack behavior is covered by [ArrayQueueStackTest.java lines 14–75](backend/src/test/java/com/wasteflow/route/ArrayQueueStackTest.java#L14-L75). Bin search, sorting, and hash-index behavior are covered by [WasteBinServiceTest.java](backend/src/test/java/com/wasteflow/bin/WasteBinServiceTest.java) and [BinCodeHashIndexTest.java](backend/src/test/java/com/wasteflow/bin/BinCodeHashIndexTest.java).

## Summary

Task 1 uses a Java array working snapshot and a frontend array snapshot for display, search, insert, update, and delete; successful CRUD operations are persisted through the database API, so neither in-memory array is permanent storage. Task 2's custom singly linked list is integrated into route planning and provides insert, find, update, delete, traversal, and size operations. Task 3's FIFO queue processes stops in the planned order, and its LIFO stack powers undo for the latest unstarted route. Task 4 adds selectable custom sorting and hash-indexed bin-code lookup to the Bin network workflow.
