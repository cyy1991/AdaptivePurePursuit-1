import java.util.*;

ArrayList<Waypoint> userPoints;
ArrayList<Waypoint> injectedPoints;
ArrayList<Waypoint> smoothedPoints;

ArrayList<Double> distancePath;
ArrayList<Double> distanceBetween; // distance between point i and point i - 1
ArrayList<Double> curvatures;

boolean userInjectedHidden;

Robot robot;
boolean following;

/**
 * Green - smoothed (darker = more curvature)
 * Red - injected
 * Blue - original
 */

void setup() {
    size(1200, 600);
    frameRate(60);

    userPoints = new ArrayList<Waypoint>();
    injectedPoints = new ArrayList<Waypoint>();
    smoothedPoints = new ArrayList<Waypoint>();

    distancePath = new ArrayList<Double>();
    distanceBetween = new ArrayList<Double>();
    curvatures = new ArrayList<Double>();

    userInjectedHidden = false;

    robot = new Robot();
    following = false;
    userPoints.add(new Waypoint(robot.getX(), robot.getY()));
}

void draw() {
    background(255);
    
    robot.update();
    robot.show();

    if(!userInjectedHidden) {
        for(Waypoint waypoint : injectedPoints) {
            drawWaypoint(waypoint, color(255, 0, 0));
        }

        for(Waypoint waypoint : userPoints) {
            drawWaypoint(waypoint, color(0, 0, 255));
        }
    }

    for(int i = 0; i < smoothedPoints.size(); i++) {
        Waypoint waypoint = smoothedPoints.get(i);
        double curvature = curvatures.get(i);
        drawWaypoint(waypoint, color(0, 255 - ((int) (128 * curvature * 50)), 0));
    }

    if(following) {
        followPath();
    }
}

void mousePressed() {
    userPoints.add(new Waypoint(mouseX / SCALE_FACTOR, mouseY / SCALE_FACTOR));
}

void keyPressed() {
    if(key == 'i') {
        int start = millis();
        injectWaypoints();
        System.out.println("Injection time: " + (millis() - start));
    }
    if(key == 's') {
        int start = millis();
        smoothWaypoints();
        System.out.println("Smoothing time: " + (millis() - start));

        start = millis();
        calculateDistances();
        System.out.println("Distance time: " + (millis() - start));

        start = millis();
        calculateCurvatures();
        System.out.println("Curvature time: " + (millis() - start));

        start = millis();
        calculateTargetVelocities();
        System.out.println("Target velocity time: " + (millis() - start));
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

        System.out.println("Smoothed Points: ");
        for(Waypoint waypoint : smoothedPoints) {
            waypoint.getVector().printInfo();
        }

        System.out.println("Distances: ");
        for(double distance : distancePath) {
            System.out.println(distance);
        }

        System.out.println("Curvatures: ");
        for(double curvature : curvatures) {
            System.out.println(curvature);
        }

        System.out.println("Target Velocities: ");
        for(Waypoint waypoint : smoothedPoints) {
            System.out.println(waypoint.getTargetVelocity());
        }
    }
    if(key == 'f') {
        following = true;
    }
}

void keyReleased() {
    if(key == 'f') {
        following = false;
    }
}

void drawWaypoint(Waypoint waypoint, color waypointColor) {
    stroke(waypointColor);
    fill(waypointColor);

    ellipse((float) waypoint.getX() * SCALE_FACTOR, (float) waypoint.getY() * SCALE_FACTOR, 10.0, 10.0);
}
