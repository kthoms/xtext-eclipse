/*******************************************************************************
 * Copyright (c) 2010 itemis AG (http://www.itemis.eu) and others.
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *******************************************************************************/
package org.eclipse.xtext.common.types;

import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;

/**
 * @author Sebastian Zarnekow - Initial contribution and API
 */
public class JvmShortAnnotationValueTest extends Assert {

	private JvmShortAnnotationValue shortAnnotationValue;

	@Before
	public void setUp() throws Exception {
		shortAnnotationValue = TypesFactory.eINSTANCE.createJvmShortAnnotationValue();
	}	
	
	@Test public void testMultiValue() {
		shortAnnotationValue.getValues().add((short)1);
		shortAnnotationValue.getValues().add((short)1);
		assertEquals(2, shortAnnotationValue.getValues().size());
	}
}
