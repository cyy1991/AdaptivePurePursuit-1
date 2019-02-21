public class Waypoint {

    private Vector pos;

    public Waypoint(double x, double y) {
        this(new Vector(x, y));
    }

    public Waypoint(Waypoint waypoint) {
        this(waypoint.getVector());
    }

    public Waypoint(Vector pos) {
        this.pos = new Vector(pos);
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
}