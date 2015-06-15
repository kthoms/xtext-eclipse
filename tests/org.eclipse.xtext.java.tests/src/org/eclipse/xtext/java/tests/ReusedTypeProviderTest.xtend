package org.eclipse.xtext.java.tests

import com.google.common.collect.Iterables
import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.builder.standalone.LanguageAccess
import org.eclipse.xtext.builder.standalone.incremental.BuildRequest
import org.eclipse.xtext.builder.standalone.incremental.IncrementalBuilder
import org.eclipse.xtext.common.types.JvmAnnotationReference
import org.eclipse.xtext.common.types.JvmAnnotationType
import org.eclipse.xtext.common.types.JvmFormalParameter
import org.eclipse.xtext.common.types.JvmGenericType
import org.eclipse.xtext.common.types.JvmOperation
import org.eclipse.xtext.common.types.access.IJvmTypeProvider
import org.eclipse.xtext.common.types.access.impl.AbstractTypeProviderTest
import org.eclipse.xtext.common.types.access.jdt.MockJavaProjectProvider
import org.eclipse.xtext.common.types.testSetups.AbstractMethods
import org.eclipse.xtext.common.types.testSetups.Bug347739ThreeTypeParamsSuperSuper
import org.eclipse.xtext.common.types.testSetups.ClassWithVarArgs
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.resource.FileExtensionProvider
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.resource.XtextResourceSet
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(XtextRunner)
@InjectWith(JavaInjectorProvider)
class ReusedTypeProviderTest extends AbstractTypeProviderTest {
	
	
	@Inject IncrementalBuilder builder
	@Inject IResourceServiceProvider resourceServiceProvider
	@Inject FileExtensionProvider extensionProvider 
	@Inject IJvmTypeProvider.Factory typeProviderFactory
	@Inject Provider<XtextResourceSet> resourceSetProvider
	
	IJvmTypeProvider typeProvider
	
	override setUp() throws Exception {
		super.setUp()
		val pathToSources = "/org/eclipse/xtext/common/types/testSetups";
		val files = MockJavaProjectProvider.readResource(pathToSources + "/files.list")
		val resourceSet = resourceSetProvider.get => [
			classpathURIContext = ReusedTypeProviderTest.getClassLoader
		]
		typeProviderFactory.createTypeProvider(resourceSet)
		val buildRequest = new BuildRequest => [
			for (file : files.filterNull) {
				val fullPath = pathToSources+"/"+file
				val url = MockJavaProjectProvider.getResource(fullPath)
				dirtyFiles += URI.createURI(url.toExternalForm)
			}
			setResourceSet(resourceSet)
		]
		val languageAccess = new LanguageAccess(emptySet, resourceServiceProvider, true);
		builder.build(buildRequest, #{'txt' -> languageAccess})
		typeProvider = typeProviderFactory.findTypeProvider(resourceSet)
	}
	
	override protected getTypeProvider() {
		return typeProvider
	}
	
	override protected getCollectionParamName() {
		"arg0"
	}
	
	@Test
	override void testFindTypeByName_AbstractMultimap_02() {
		var String typeName="com.google.common.collect.AbstractMultimap" 
		var JvmGenericType type=getTypeProvider().findTypeByName(typeName) as JvmGenericType 
		var JvmOperation containsValue=Iterables.getOnlyElement(type.findAllFeaturesByName("containsValue")) as JvmOperation 
		assertNotNull(containsValue) var JvmFormalParameter firstParam=containsValue.getParameters().get(0) 
		assertEquals(1, firstParam.getAnnotations().size()) var JvmAnnotationReference annotationReference=firstParam.getAnnotations().get(0) 
		var JvmAnnotationType annotationType=annotationReference.getAnnotation() 
		assertTrue(annotationType.eIsProxy()) assertEquals("java:/Objects/javax.annotation.Nullable", EcoreUtil.getURI(annotationType).trimFragment().toString()) 
	}
	
	@Test
	override void testParameterNames_01() {
		doTestParameterName(Bug347739ThreeTypeParamsSuperSuper, "getToken(A)", "arg0");
	}
	@Test
	override void testParameterNames_02() {
		doTestParameterName(AbstractMethods, "abstractMethodWithParameter(java.lang.String)", "arg0");
	}
	@Test
	override void testParameterNames_03() {
		doTestParameterName(ClassWithVarArgs, "method(java.lang.String[])", "arg0");
	}
	
}