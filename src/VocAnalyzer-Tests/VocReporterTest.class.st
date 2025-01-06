"
A VocReporterTest is a test class for testing the behavior of VocReporter
"
Class {
	#name : 'VocReporterTest',
	#superclass : 'TestCase',
	#category : 'VocAnalyzer-Tests',
	#package : 'VocAnalyzer-Tests'
}

{ #category : 'tests' }
VocReporterTest >> testMethodNames [

	| voc |
	voc := VocReporter new. 
	voc packagePatterns: #('VocanalyzerDataPackage*').
	voc computedMatchedPatterns.
	self 
		assert: voc methodNames equals: #(x123 xy) asSet
]

{ #category : 'tests' }
VocReporterTest >> testNumberOfClasses [

	| voc |
	voc := VocReporter new. 
	voc packagePatterns: #('Voc*').
	voc computedMatchedPatterns.
	self 
		assert: voc numberOfClasses equals: 5
		
]

{ #category : 'tests' }
VocReporterTest >> testPackagePatterns [

	| voc |
	voc := VocReporter new. 
	voc packagePatterns: #('Voc*').
	voc computedMatchedPatterns.
	self 
		assert: (voc matchedPackages collect: [ :each | each name ]) asSet 
		equals: #('Vocanalyzer' 'VocanalyzerDataPackage1' 'VocanalyzerDataPackage2') asSet.
]

{ #category : 'tests' }
VocReporterTest >> testUniqueSelectors [

	| voc |
	voc := VocReporter new. 
	voc packagePatterns: #('VocanalyzerDataPackage*').
	voc computedMatchedPatterns.
	self 
		assert: voc uniqueMethods size equals: 4
]
