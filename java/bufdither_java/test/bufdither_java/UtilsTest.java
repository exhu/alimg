/*
 * To change this template, choose Tools | Templates
 * and open the template in the editor.
 */
package bufdither_java;

import org.junit.After;
import org.junit.AfterClass;
import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.BeforeClass;
import org.junit.Test;

/**
 *
 * @author yur
 */
public class UtilsTest {
    
    public UtilsTest() {
    }
    
    @BeforeClass
    public static void setUpClass() {
    }
    
    @AfterClass
    public static void tearDownClass() {
    }
    
    @Before
    public void setUp() {
    }
    
    @After
    public void tearDown() {
    }

    /**
     * Test of nextPowerOfTwo method, of class Utils.
     */
    @Test
    public void testNextPowerOfTwo() {
        System.out.println("nextPowerOfTwo");
        int n = 0;
        int expResult = 0;
        int result = Utils.nextPowerOfTwo(n);
        assertEquals(expResult, result);
        
        n = 3;
        expResult = 4;
        result = Utils.nextPowerOfTwo(n);
        assertEquals(expResult, result);
        
    }
}
