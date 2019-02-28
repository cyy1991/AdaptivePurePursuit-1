public class Waypoint {

    private Vector pos;
    private double targetVelocity;

    public Waypoint(double x, double y) {
        this(new Vector(x, y));
    }

    public Waypoint(Waypoint waypoint) {
        this(waypoint.getVector());
    }

    public Waypoint(Vector pos) {
        this.pos = new Vector(pos);
        targetVelocity = -1.0;
    }

    public double getDistanceTo(Waypoint other) {
        return this.pos.getDistanceTo(other.getVector());
    }

    public double getDistanceTo(double x, double y) {
        return this.pos.getDistanceTo(new Vector(x, y));
    }

    public double getX() {
        return this.pos.getX();
    }

    public double getY() {
        return this.pos.getY();
    }

    public void setX(double x) {
        this.pos.setX(x);
    }

    public void setY(double y) {
        this.pos.setY(y);
    }

    public Vector getVector() {
        return pos;
    }

    public double getTargetVelocity() {
        return this.targetVelocity;
    }

    public void setTargetVelocity(double targetVelocity) {
        this.targetVelocity = targetVelocity;
    }
}