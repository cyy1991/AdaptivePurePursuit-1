import java.util.*;

ArrayList<Waypoint> userPoints;
ArrayList<Waypoint> injectedPoints;
ArrayList<Waypoint> smoothedPoints;

boolean userInjectedHidden;

/**
 * Green - smoothed
 * Red - injected
 * Blue - original
 */

void setup() {
    size(1200, 600);

    userPoints = new ArrayList<Waypoint>();
    injectedPoints = new ArrayList<Waypoint>();
    smoothedPoints = new ArrayList<Waypoint>();

    userInjectedHidden = false;
}

void draw() {
    background(255);

    if(!userInjectedHidden) {
        for(Waypoint waypoint : injectedPoints) {
            drawWaypoint(waypoint, color(255, 0, 0));
        }

        for(Waypoint waypoint : userPoints) {
            drawWaypoint(waypoint, color(0, 0, 255));
        }
    }

    for(Waypoint waypoint : smoothedPoints) {
        drawWaypoint(waypoint, color(0, 255, 0));
    }
}

void mousePressed() {
    userPoints.add(new Waypoint(mouseX, mouseY));
}

void keyPressed() {
    if(key == 'i') {
        System.out.println("Injection start time: " + millis());
        injectWaypoints();
        System.out.println("Injection end time: " + millis());
    }
    if(key == 's') {
        System.out.println("Smoothing start time: " + millis());
        smoothWaypoints();
        System.out.println("Smoothing end time: " + millis());
    }
    if(key == 'r') {
        userPoints.clear();
        injectedPoints.clear();
        smoothedPoints.clear();
    }
    if(key == 'h') {
        userInjectedHidden = !userInjectedHidden;
    }
    if(key == 'p') {
        System.out.println("User Points: ");
        for(Waypoint waypoint : userPoints) {
            waypoint.getVector().printInfo();
        }

        System.out.println("Injected Points: ");
        for(Waypoint waypoint : injectedPoints) {
            waypoint.getVector().printInfo();
        }
    }
}

void injectWaypoints() {
    injectedPoints.clear();

    // Loop through all segments
    for(int i = 0; i < userPoints.size() - 1; i++) {
        Waypoint a = userPoints.get(i);
        Waypoint b = userPoints.get(i + 1);

        Vector vector = b.getVector().sub(a.getVector());
        int numPoints = (int) Math.ceil(vector.getMag() / SPACING);
        Vector dVector = vector.normalize().mult(SPACING);

        for(int j = 0; j < numPoints; j++) {
            injectedPoints.add(new Waypoint(a.getVector().add(dVector.mult(j))));
        }
    }
    injectedPoints.add(userPoints.get(userPoints.size() - 1));
}

void smoothWaypoints() {
    smoothedPoints.clear();

    for(Waypoint waypoint : injectedPoints) {
        smoothedPoints.add(new Waypoint(waypoint));
    }

    double change = TOLERANCE;
    while(change >= TOLERANCE) {
        change = 0.0;
        for(int i = 1; i < smoothedPoints.size() - 1; i++) {
            Waypoint current = smoothedPoints.get(i);
            Waypoint prev = smoothedPoints.get(i - 1);
            Waypoint next = smoothedPoints.get(i + 1);

            Waypoint origCurrent = injectedPoints.get(i);

            // x smoothing
            double compX = current.getX();
            double newX = current.getX() + WEIGHT_DATA * (origCurrent.getX() - current.getX()) + 
                WEIGHT_SMOOTH * (prev.getX() + next.getX() - (2 * current.getX()));
            current.setX(newX);
            change += Math.abs(compX - newX);

            // y smoothing
            double compY = current.getY();
            double newY = current.getY() + WEIGHT_DATA * (origCurrent.getY() - current.getY()) + 
                WEIGHT_SMOOTH * (prev.getY() + next.getY() - (2 * current.getY()));
            current.setY(newY);
            change += Math.abs(compY - newY);
        }
    }
}

void drawWaypoint(Waypoint waypoint, color waypointColor) {
    stroke(waypointColor);
    fill(waypointColor);

    ellipse((float) waypoint.getX(), (float) waypoint.getY(), 10.0, 10.0);
}
