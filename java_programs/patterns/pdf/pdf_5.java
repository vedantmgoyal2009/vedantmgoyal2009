package java_programs.patterns.pdf;

import java.util.Scanner;

/*  1
    1 0
    1 0 1
    1 0 1 0
*/
public class pdf_5 {
  public static void main(String[] args) {
    Scanner sc = new Scanner(System.in);
    System.out.println("Enter no. of lines to print : ");
    int lines = sc.nextInt();
    for (int i = 1; i <= lines; i++) {
      for (int j = 1; j <= i; j++) System.out.print(j % 2 + " ");
      System.out.println();
    }
    sc.close();
  }
}
