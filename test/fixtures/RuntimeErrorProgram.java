import java.util.ArrayList;
public class RuntimeErrorProgram {
  public static void main(String[] args) {
    ArrayList<Integer> list = new ArrayList<>();
    list.get(10);
  }
}