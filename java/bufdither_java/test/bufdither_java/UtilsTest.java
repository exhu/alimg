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
    
    @Test
    public void testBitsForInt() {
        System.out.println("bitsForInt");
        assertEquals(4, Utils.bitsForInt(15));
        assertEquals(8, Utils.bitsForInt(255));
        assertEquals(15, Utils.bitsForInt(32767));
        assertEquals(16, Utils.bitsForInt(65535));
        
    }
    
    @Test
    public void testSwOfs() {
        int w = 1024;
        int h = 1024;
        int bits = Utils.bitsForInt(w-1);
        int ofs = Utils.swOfs(0, 0, bits);
        assertEquals(0, ofs);
        ofs = Utils.swOfs(1, 0, bits);
        assertEquals(4, ofs);
        ofs = Utils.swOfs(2, 0, bits);
        assertEquals(8, ofs);
        ofs = Utils.swOfs(0, 1, bits);
        assertEquals(16, ofs);
        ofs = Utils.swOfs(w-1, h-1, bits);
        assertEquals((h-1)*w*4 + (w-1)*4, ofs);
        
    }
    
    
    
    
}
