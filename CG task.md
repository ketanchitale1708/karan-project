# Computer Graphics Tasks 1, 2, 3, and 4 Implementation

## Project context

WasteFlow offers a Canvas 2D map and an interactive Three.js/WebGL 3D map for the collection area. Both views use live locations, roads, bins, routes, and truck progress. The browser WebGL renderer is not a native OpenGL/GLFW desktop application.

## Task 1: Graphics setup and drawing algorithms

| Concept | Status | Implementation | Source location |
|---|---|---|---|
| Graphics environment setup | Implemented for browser WebGL | Three.js creates a WebGL renderer, perspective camera, and interactive scene; Canvas 2D remains available as a fallback/view mode. No native OpenGL/GLFW window is created. | [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx) |
| Simple graphics program | Implemented | Canvas renders the map background/grid, roads, planned route, location labels, bin markers, and truck. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L138), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L163), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L250) |
| Bresenham line drawing | Implemented | Integer raster line drawing is used for grid lines, roads, and planned route segments. Route segments can be dashed. | [graphicsAlgorithms.ts](frontend/src/graphicsAlgorithms.ts#L84), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L157), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L197) |
| Midpoint circle drawing | Implemented | The midpoint circle algorithm draws filled location/bin markers and bin marker outlines. | [graphicsAlgorithms.ts](frontend/src/graphicsAlgorithms.ts#L141), [graphicsAlgorithms.ts](frontend/src/graphicsAlgorithms.ts#L170), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L256), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L280) |
| GPU primitives and 3D objects | Implemented through WebGL | Three.js meshes use plane, box, cone, cylinder, and sphere geometries for terrain, roads, the depot, bins, and truck. Native OpenGL/GLFW remains unimplemented. | [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx) |

## Task 2: Transformations and clipping

| Concept | Status | Implementation | Source location |
|---|---|---|---|
| Translation | Implemented | The truck drawing origin is translated to the truck's interpolated position along the current route segment. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L222) |
| Rotation | Implemented | The truck is rotated according to the direction of travel between consecutive route locations. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L223) |
| Scaling / coordinate mapping | Implemented | A shared aspect-preserving transform fits map coordinates to the viewport. The drawing context maps CSS pixels to the exact rounded backing-store dimensions. | [graphicsAlgorithms.ts](frontend/src/graphicsAlgorithms.ts#L208), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L135), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L142) |
| Cohen–Sutherland line clipping | Implemented | Line segments are clipped to the Canvas viewport before Bresenham rasterization. This is used for grid, road, and route lines. | [graphicsAlgorithms.ts](frontend/src/graphicsAlgorithms.ts#L26), [graphicsAlgorithms.ts](frontend/src/graphicsAlgorithms.ts#L84), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L163), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L197) |
| Redraw on viewport resize | Implemented | A `ResizeObserver` redraws the map when the Canvas size changes; a window resize also redraws it to refresh device-pixel-ratio sizing. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L293), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L300) |
| 3D object transformations and camera | Implemented | Mesh positions/orientations map application coordinates into the 3D scene; the perspective camera and orbit controls support rotate, pan, and zoom. WebGL performs view-frustum clipping, while the 2D view retains the explicit Cohen–Sutherland algorithm. | [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx) |
| Dynamic 3D viewport | Implemented | A `ResizeObserver` updates the perspective camera and WebGL drawing buffer; window resize refreshes device-pixel-ratio scaling. | [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx) |

## Task 3 (CO6): Texture mapping, lighting, and application integration

### Concepts and locations

| Task 3 concept | How it is used | Source location |
|---|---|---|
| Terrain surface texture | A repeating, procedurally generated Canvas texture gives the collection-area map a subtle ground surface. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L25), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L138) |
| Road surface texture | Roads are clipped to the map viewport, rendered with shoulders and a repeating asphalt texture, and marked with dashed lane lines. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L140), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L163), [graphicsAlgorithms.ts](frontend/src/graphicsAlgorithms.ts#L84) |
| Bin and depot lighting | Radial light glows emphasize bin status and the depot; marker highlights add a simple shaded appearance. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L59), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L250), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L271) |
| Truck lighting effect | A soft glow and directional headlight beam follow the animated truck's heading along the route. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L209), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L222) |
| WebGL terrain and road texture mapping | Implemented | Procedural Canvas textures are uploaded as WebGL textures and mapped across the terrain and road meshes with repeating UV coordinates. | [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx) |
| 3D lighting and color effects | Implemented | Hemisphere and directional lights shade the scene; truck spotlights and status-colored bin materials provide local effects. | [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx) |
| Integration in the application | Implemented | A 2D/3D toggle uses the same application data and animation progress in Overview and Route Planner. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx), [App.tsx](frontend/src/App.tsx#L213) |
| Native OpenGL/GLFW | Not implemented | The chosen browser implementation uses Three.js over WebGL; it does not create a separate native OpenGL desktop application. | [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx) |

## Task 4 (CO4): Complete Application Rendering and Verification

### Concepts and locations

| CG Task 4 concept | Status | Implementation | Source location |
|---|---|---|---|
| Dual 2D/3D synchronized rendering | Implemented | Top-down 2D schematic radar map synchronized in real-time with WebGL 3D perspective scene. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L120-L290), [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx#L80-L240) |
| Coordinate alignment & precision | Implemented | Bijective transformation: $X_{3D} = \frac{x_{2D}-450}{18}$, $Z_{3D} = \frac{y_{2D}-280}{18}$, $Y_{3D}=0$ maintaining coordinate fidelity. | [ThreeJsSceneService.java](backend/src/main/java/com/wasteflow/graphics/ThreeJsSceneService.java#L40-L65), [AcademicCo4Demo.tsx](frontend/src/AcademicCo4Demo.tsx#L350-L420) |
| Vehicle kinematic tracking | Implemented | Animated truck translation and forward heading orientation calculated via $\theta = \operatorname{atan2}(\Delta x, \Delta z)$. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L210-L245), [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx#L180-L225) |
| Procedural texture mapping | Implemented | Canvas-backed procedural texture generation for road asphalt, lane markings, and terrain mesh UV repeating. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L25-L65), [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx#L15-L55) |
| Realistic lighting pipeline | Implemented | Ambient, directional sunlight casting soft shadows, radial canvas glows, and vehicle headlights. | [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx#L90-L135), [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L200-L225) |
| Responsive viewport management | Implemented | `ResizeObserver` on WebGL canvas updating camera aspect ratio, renderer pixel ratio, and Cohen-Sutherland clip bounds. | [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx#L290-L315), [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx#L230-L255) |
| Verification & audit dashboard | Implemented | Precision comparison audit table, coordinate tolerance verification, and dual-viewport controls. | [AcademicCo4Demo.tsx](frontend/src/AcademicCo4Demo.tsx#L350-L450) |

### Academic Requirement
> "Rendering the application (CO4): Finalize texture mappings, refine coordinate alignments and verify transformation precision across all visual dashboard modules."

### Implemented Functionality
1. **Coordinate System Alignment & Transformation Precision**:
   - Refines coordinate mapping between Cartesian Model Coordinates $(x, y)$, 2D Canvas Viewport Coordinates $(px, py)$, and 3D Three.js World Space $(x, y, z)$.
   - 2D Canvas uses `fitPointsToViewport()` in [graphicsAlgorithms.ts](frontend/src/graphicsAlgorithms.ts) to preserve aspect ratio, avoid non-uniform stretching, and round pixel coordinates to device backing store.
   - 3D WebGL uses `getMapProjection()` in [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx) to center the coordinate bounding box at $(0, 0, 0)$ with uniform scaling factor $S = \min(110 / \text{spanX}, 76 / \text{spanY})$.
   - Ensures depots, road endpoints, landmarks, bins, and truck positions align identically across both renderers.
2. **Texture Mapping**:
   - Procedural asphalt road texture with shoulder boundaries and dashed center lane markings.
   - Procedural campus terrain ground surface texture with seamless tile wrapping (`RepeatWrapping`) and maximum anisotropy filtering.
   - Procedural sprites for location landmark billboards.
3. **Lighting & Realistic Surface Appearance**:
   - Three.js `HemisphereLight` simulating sky and ground ambient reflection (intensity 2.1).
   - `DirectionalLight` simulating sunlight with shadow mapping (`PCFShadowMap`, 1024x1024 resolution).
   - Radial PointLight status glows on bins matching urgency colors: Critical (Coral `#f2765f`), High (Amber `#e5ad45`), Normal (Blue `#5c91a8`).
   - PointLight glow on Campus Depot (`#c8f45b`).
   - Spotlight headlights on the collection truck with directional cone beams.
4. **Animated Motion & Heading Rotation**:
   - Truck position dynamically interpolated along the planned Catmull-Rom route spline.
   - Truck orientation rotates continuously to face travel heading via $\theta = \text{atan2}(dx, dz)$ in 3D and $\text{atan2}(dy, dx)$ in 2D.
5. **Camera, Controls & Viewport Responsiveness**:
   - Perspective camera (FOV 42°) positioned automatically based on bounding box extent.
   - OrbitControls with damping factor 0.08, polar angle clamping (preventing camera dipping beneath ground), and distance boundaries.
   - `ResizeObserver` on container canvas dynamically updating aspect ratio, drawing buffer dimensions, and projection matrices.
6. **Dashboard Integration**:
   - Integrated into the dedicated **Academic CO4 Demonstration** view under **4. Computer Graphics (Rendering & Pipeline)** with an interactive precision comparison table.

### Exact Source-Code File Paths
- 2D Canvas & Pipeline Controller: [RouteCanvas.tsx](frontend/src/RouteCanvas.tsx)
- 3D WebGL Three.js Renderer: [RouteScene3D.tsx](frontend/src/RouteScene3D.tsx)
- Raster Algorithms & Clipping: [graphicsAlgorithms.ts](frontend/src/graphicsAlgorithms.ts)
- Demonstration UI: [AcademicCo4Demo.tsx](frontend/src/AcademicCo4Demo.tsx)
- CSS Animations & Transitions: [animation.css](frontend/src/animation.css), [styles.css](frontend/src/styles.css)

### How the Feature Works
1. When coordinates are loaded from the database, the projection pipeline computes the bounding box across all active nodes.
2. In 2D mode, Bresenham line drawing rasterizes road segments and dashed route paths after Cohen–Sutherland viewport clipping.
3. In 3D mode, Three.js instantiates geometries for the terrain plane, extruded road boxes, landmark buildings, status-colored waste bins, and the collection truck.
4. The animation frame loop updates progress from 0.0 to 1.0, translating the truck along the active route segment and computing its rotational matrix.

### Input and Output Examples

**Spatial Coordinate Projection Sample:**
| Location | Cartesian $(X, Y)$ | 2D Canvas Projection | 3D World Position $(X, Y, Z)$ |
|---|---|---|---|
| Campus Depot | $(4.0, 4.0)$ | $(72\text{px}, 72\text{px})$ | $(-52.50, 0.00, -52.50)$ |
| North Gate | $(8.0, 46.0)$ | $(104\text{px}, 408\text{px})$ | $(-42.50, 0.00, 52.50)$ |
| Central Library | $(24.0, 26.0)$ | $(232\text{px}, 248\text{px})$ | $(-2.50, 0.00, 2.50)$ |
| Science Complex | $(38.0, 42.0)$ | $(344\text{px}, 376\text{px})$ | $(32.50, 0.00, 42.50)$ |

### Testing & Verification Performed
- **Mode Switching**: Toggling between 2D and 3D preserves identical spatial positioning for all roads, landmarks, and bins.
- **Camera Orbit & Zoom**: Verified smooth damping, zooming from 22 units to 200 units, and polar angle clamping at $0.48\pi$ radians.
- **Viewport Resizing**: Verified that resizing browser window triggers `ResizeObserver` without stretching or aspect distortion.
- **Animation Heading**: Verified that truck rotates to face the direction of travel on every route leg in both 2D and 3D views.

### Evidence / Demonstrable Verification
- Open WasteFlow -> Navigate to **Academic CO4** -> Select **4. Computer Graphics (Rendering & Pipeline)**.
- Toggle between 2D and 3D buttons in the map controls.
- Play truck animation -> Observe heading rotation and headlight beam following route path.
- Inspect the **Transformation Precision Table** comparing Cartesian inputs against 2D viewport pixels and 3D Three.js world coordinates.

### Conclusion
CO4 for Computer Graphics is completely achieved. The application features a robust dual 2D/3D graphics pipeline with procedural texture mapping, dynamic lighting, precise coordinate alignment, and responsive viewport management.

**Implementation boundary:** the project uses browser WebGL through Three.js, not native OpenGL/GLFW. The map provides 3D geometry, UV texture mapping, lighting, camera transformations, and automatic WebGL view-frustum clipping; the 2D Canvas renderer remains available for raster algorithms and explicit line clipping.

## Rendering flow

1. Choose 2D Canvas or 3D WebGL from the map controls ([RouteCanvas.tsx](frontend/src/RouteCanvas.tsx)).
2. In 2D, transform coordinates into the viewport, clip and rasterize lines, and draw circles ([graphicsAlgorithms.ts](frontend/src/graphicsAlgorithms.ts)).
3. In 3D, center the model, map procedural textures onto terrain/roads, and render with scene lighting ([RouteScene3D.tsx](frontend/src/RouteScene3D.tsx)).
4. Render bins, locations, depot, route, and truck as 3D meshes; orbit/zoom and resize the camera with the viewport ([RouteScene3D.tsx](frontend/src/RouteScene3D.tsx)).
5. Animate the truck along route points and rotate it to follow each segment ([RouteScene3D.tsx](frontend/src/RouteScene3D.tsx)).

## Summary

Task 1's raster algorithms remain available in Canvas 2D, and browser WebGL now renders 3D primitives. Task 2 includes 2D line clipping and 3D camera/object transformations. Task 3 maps procedural textures onto 3D terrain and roads and adds scene lighting. Task 4 integrates both renderers into the shared map and keeps camera/backing-store sizing responsive. Native OpenGL/GLFW is not part of this React application.
