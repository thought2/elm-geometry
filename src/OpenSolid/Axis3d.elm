--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- This Source Code Form is subject to the terms of the Mozilla Public        --
-- License, v. 2.0. If a copy of the MPL was not distributed with this file,  --
-- you can obtain one at http://mozilla.org/MPL/2.0/.                         --
--                                                                            --
-- Copyright 2016 by Ian Mackenzie                                            --
-- ian.e.mackenzie@gmail.com                                                  --
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------


module OpenSolid.Axis3d
    exposing
        ( Axis3d
        , direction
        , flip
        , mirrorAcross
        , moveTo
        , originPoint
        , placeIn
        , projectInto
        , projectOnto
        , relativeTo
        , rotateAround
        , translateBy
        , with
        , x
        , y
        , z
        )

{-| <img src="https://opensolid.github.io/images/geometry/icons/axis3d.svg" alt="Axis3d" width="160">

An `Axis3d` represents an infinitely long straight line in 3D and is defined by
an origin point and direction. Axes have several uses, such as:

  - Rotating around the axis
  - Projecting onto the axis
  - Measuring distance along the axis

@docs Axis3d


# Predefined axes

@docs x, y, z


# Constructors

@docs with


# Accessors

@docs originPoint, direction


# Transformations

@docs flip, moveTo, rotateAround, translateBy, mirrorAcross, projectOnto


# Coordinate frames

Functions for transforming axes between local and global coordinates in
different coordinate frames.

@docs relativeTo, placeIn


# Sketch planes

@docs projectInto

-}

import OpenSolid.Axis2d as Axis2d exposing (Axis2d)
import OpenSolid.Direction3d as Direction3d exposing (Direction3d)
import OpenSolid.Geometry.Internal as Internal exposing (Frame3d, Plane3d, SketchPlane3d)
import OpenSolid.Point3d as Point3d exposing (Point3d)
import OpenSolid.Vector3d as Vector3d exposing (Vector3d)


{-| An axis in 3D.
-}
type alias Axis3d =
    Internal.Axis3d


{-| The global X axis.

    Axis3d.x
    --> Axis3d.with
    -->     { originPoint = Point3d.origin
    -->     , direction = Direction3d.x
    -->     }

-}
x : Axis3d
x =
    with { originPoint = Point3d.origin, direction = Direction3d.x }


{-| The global Y axis.

    Axis3d.y
    --> Axis3d.with
    -->     { originPoint = Point3d.origin
    -->     , direction = Direction3d.y
    -->     }

-}
y : Axis3d
y =
    with { originPoint = Point3d.origin, direction = Direction3d.y }


{-| The global Z axis.

    Axis3d.z
    --> Axis3d.with
    -->     { originPoint = Point3d.origin
    -->     , direction = Direction3d.z
    -->     }

-}
z : Axis3d
z =
    with { originPoint = Point3d.origin, direction = Direction3d.z }


{-| Construct an axis from its origin point and direction:

    exampleAxis =
        Axis3d.with
            { originPoint = Point3d.withCoordinates ( -2, 1, 3 )
            , direction = Direction3d.withComponents ( 0, 0.8, -0.6 )
            }

-}
with : { originPoint : Point3d, direction : Direction3d } -> Axis3d
with =
    Internal.Axis3d


{-| Get the origin point of an axis.

    Axis3d.originPoint exampleAxis
    --> Point3d.withCoordinates ( -2, 1, 3 )

-}
originPoint : Axis3d -> Point3d
originPoint (Internal.Axis3d properties) =
    properties.originPoint


{-| Get the direction of an axis.

    Axis3d.direction exampleAxis
    --> Direction3d.withComponents ( 0, 0.8, -0.6 )

-}
direction : Axis3d -> Direction3d
direction (Internal.Axis3d properties) =
    properties.direction


{-| Reverse the direction of an axis while keeping the same origin point.

    Axis3d.flip exampleAxis
    --> Axis3d.with
    -->     { originPoint = Point3d.withCoordinates ( -2, 1, 3 )
    -->     , direction = Direction3d.withComponents ( 0, -0.8, 0.6 )
    -->     }

-}
flip : Axis3d -> Axis3d
flip axis =
    with
        { originPoint = originPoint axis
        , direction = Direction3d.flip (direction axis)
        }


{-| Move an axis so that it has the given origin point but unchanged direction.

    newOrigin =
        Point3d.withCoordinates ( 3, 4, 5 )

    Axis3d.moveTo newOrigin exampleAxis
    --> Axis3d.with
    -->     { originPoint = Point3d.withCoordinates ( 3, 4, 5 ),
    -->     , direction = Direction3d.withComponents ( 0, 0.8, -0.6 )
    -->     }

-}
moveTo : Point3d -> Axis3d -> Axis3d
moveTo newOrigin axis =
    with { originPoint = newOrigin, direction = direction axis }


{-| Rotate an axis around another axis by a given angle. The axis to rotate
around is given first and the axis to rotate is given last.

    Axis3d.rotateAround Axis3d.z (degrees 90) exampleAxis
    --> Axis3d.with
    -->     { originPoint = Point3d.withCoordinates ( -1, -2, 3 )
    -->     , direction = Direction3d.withComponents ( -0.8, 0, -0.6 )
    -->     }

-}
rotateAround : Axis3d -> Float -> Axis3d -> Axis3d
rotateAround otherAxis angle =
    let
        rotatePoint =
            Point3d.rotateAround otherAxis angle

        rotateDirection =
            Direction3d.rotateAround otherAxis angle
    in
    \axis ->
        with
            { originPoint = rotatePoint (originPoint axis)
            , direction = rotateDirection (direction axis)
            }


{-| Translate an axis by a given displacement. Applies the given displacement to
the axis' origin point and leaves the direction unchanged.

    displacement =
        Vector3d.withComponents ( 3, 3, 3 )

    Axis3d.translateBy displacement exampleAxis
    --> Axis3d.with
    -->     { originPoint = Point3d.withCoordinates ( 1, 4, 6 )
    -->     , direction = Direction3d.withComponents ( 0, 0.8, -0.6 )
    -->     }

-}
translateBy : Vector3d -> Axis3d -> Axis3d
translateBy vector axis =
    with
        { originPoint = Point3d.translateBy vector (originPoint axis)
        , direction = direction axis
        }


{-| Mirror an axis across a plane.

    Axis3d.mirrorAcross Plane3d.xy exampleAxis
    --> Axis3d.with
    -->     { originPoint = Point3d.withCoordinates ( -2, 1, -3 )
    -->     , direction = Direction3d.withComponents ( 0, 0.6, 0.8 )
    -->     }

-}
mirrorAcross : Plane3d -> Axis3d -> Axis3d
mirrorAcross plane =
    let
        mirrorPoint =
            Point3d.mirrorAcross plane

        mirrorDirection =
            Direction3d.mirrorAcross plane
    in
    \axis ->
        with
            { originPoint = mirrorPoint (originPoint axis)
            , direction = mirrorDirection (direction axis)
            }


{-| Project an axis onto a plane, returning the axis that is the 'shadow' of the
given axis on the given plane. If the given axis is exactly perpendicular to the
given plane, returns `Nothing`.

    Axis3d.projectOnto Plane3d.xy exampleAxis
    --> Just
    -->     (Axis3d.with
    -->         { originPoint = Point3d.withCoordinates ( -2, 1, 0 )
    -->         , direction = Direction3d.withComponents ( 0, 1, 0 )
    -->         }
    -->     )

    Axis3d.projectOnto Plane3d.xy Axis3d.z
    --> Nothing

-}
projectOnto : Plane3d -> Axis3d -> Maybe Axis3d
projectOnto plane axis =
    let
        projectedOrigin =
            Point3d.projectOnto plane (originPoint axis)

        toAxis direction =
            with { originPoint = projectedOrigin, direction = direction }
    in
    Maybe.map toAxis (Direction3d.projectOnto plane (direction axis))


{-| Take an axis defined in global coordinates, and return it expressed in local
coordinates relative to a given reference frame.

    originPoint =
        Point3d.withCoordinates ( 3, 3, 3 )

    Axis3d.relativeTo (Frame3d.at originPoint) exampleAxis
    --> Axis3d.with
    -->     { originPoint = Point3d.withCoordinates ( -5, -2, 0 )
    -->     , direction = Direction3d.withComponents ( 0, 0.8, -0.6 )
    -->     }

-}
relativeTo : Frame3d -> Axis3d -> Axis3d
relativeTo frame =
    let
        relativePoint =
            Point3d.relativeTo frame

        relativeDirection =
            Direction3d.relativeTo frame
    in
    \axis ->
        with
            { originPoint = relativePoint (originPoint axis)
            , direction = relativeDirection (direction axis)
            }


{-| Take an axis defined in local coordinates relative to a given reference
frame, and return that axis expressed in global coordinates.

    originPoint =
        Point3d.withCoordinates ( 3, 3, 3 )

    Axis3d.placeIn (Frame3d.at originPoint) exampleAxis
    --> Axis3d.with
    -->     { originPoint = Point3d.withCoordinates ( 1, 4, 6 )
    -->     , direction = Direction3d.withComponents ( 0, 0.8, -0.6 )
    -->     }

-}
placeIn : Frame3d -> Axis3d -> Axis3d
placeIn frame =
    let
        placePoint =
            Point3d.placeIn frame

        placeDirection =
            Direction3d.placeIn frame
    in
    \axis ->
        with
            { originPoint = placePoint (originPoint axis)
            , direction = placeDirection (direction axis)
            }


{-| Project an axis into a given sketch plane. Conceptually, this projects the
axis onto the plane and then expresses the projected axis in 2D sketch
coordinates.

This is only possible if the axis is not perpendicular to the sketch
plane; if it is perpendicular, `Nothing` is returned.

    Axis3d.projectInto SketchPlane3d.yz exampleAxis
    --> Just
    -->     (Axis2d.with
    -->         { originPoint = Point2d.withCoordinates ( 1, 3 )
    -->         , direction = Direction2d.withComponents ( 0.8, -0.6 )
    -->         }
    -->     )

    Axis3d.projectInto SketchPlane3d.xy exampleAxis
    --> Just
    -->     (Axis2d.with
    -->         { originPoint = Point2d.withCoordinates ( -2, 1 )
    -->         , direction = Direction3d.withComponents ( 0, 1 )
    -->         }
    -->     )

    Axis3d.projectInto SketchPlane3d.xy Axis3d.z
    --> Nothing

-}
projectInto : SketchPlane3d -> Axis3d -> Maybe Axis2d
projectInto sketchPlane axis =
    let
        projectedOrigin =
            Point3d.projectInto sketchPlane (originPoint axis)

        toAxis direction =
            Axis2d.with { originPoint = projectedOrigin, direction = direction }
    in
    Maybe.map toAxis (Direction3d.projectInto sketchPlane (direction axis))
