import java.util.*;

ArrayList<Waypoint> userPoints;
ArrayList<Waypoint> injectedPoints;

void setup() {
    size(1200, 600);

    userPoints = new ArrayList<Waypoint>();
    injectedPoints = new ArrayList<Waypoint>();

    Vector v = new Vector(3, 4);
}

void draw() {
    background(255);

    for(Waypoint waypoint : injectedPoints) {
        drawWaypoint(waypoint, color(255, 0, 0));
    }

    for(Waypoint waypoint : userPoints) {
        drawWaypoint(waypoint, color(0, 0, 255));
    }
}

void mousePressed() {
    userPoints.add(new Waypoint(mouseX, mouseY));
}

void keyPressed() {
    if(key == 'i') {
        System.out.println("Start time: " + millis());
        injectWaypoints();
        System.out.println("End time: " + millis());
    }
    if(key == 'r') {
        userPoints.clear();
        injectedPoints.clear();
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

void drawWaypoint(Waypoint waypoint, color waypointColor) {
    stroke(waypointColor);
    fill(waypointColor);

    ellipse((float) waypoint.getX(), (float) waypoint.getY(), 10.0, 10.0);
}
