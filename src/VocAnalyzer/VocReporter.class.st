"
""VocReporter is a utility class that analyzes and reports information about Smalltalk packages. 
It focuses on identifying packages that match specific patterns, computing metrics such as the ratio 
of classes to matched packages, and extracting method and class information from these packages. 
It serves as a key component in the Vocanalyzer framework for package analysis.""

"
Class {
	#name : 'VocReporter',
	#superclass : 'Object',
	#instVars : [
		'packagePatterns',
		'matchedPackages'
	],
	#category : 'VocAnalyzer',
	#package : 'VocAnalyzer'
}

{ #category : 'as yet unclassified' }
VocReporter >> classPackageRatio [
	
	^ (self numberOfClasses / self matchedPackages size) asFloat
]

{ #category : 'as yet unclassified' }
VocReporter >> computedMatchedPatterns [
	
	self packageOrganizer packageNamesDo: [ :each | (packagePatterns anySatisfy: [ :pat | pat match: each ])
																	ifTrue: [ matchedPackages add: (self packageOrganizer packageNamed: each) ] ]
]

{ #category : 'as yet unclassified' }
VocReporter >> initialize [

	super initialize.
	matchedPackages := OrderedCollection new.
]

{ #category : 'as yet unclassified' }
VocReporter >> matchedPackages [

	^ matchedPackages
]

{ #category : 'as yet unclassified' }
VocReporter >> matchedPackages: anObject [

	matchedPackages := anObject
]

{ #category : 'as yet unclassified' }
VocReporter >> methodNames [
	
	| results | 
	results := Set new. 
	matchedPackages do: [ :each | results addAll: each selectors ].
	^ results 
]

{ #category : 'as yet unclassified' }
VocReporter >> numberOfClasses [
	
	| n |
	n := 0.
	matchedPackages do: [ :each | 
		n := n + each definedClasses size]. 
	^ n 
]

{ #category : 'as yet unclassified' }
VocReporter >> packagePatterns: aCollection [ 

	packagePatterns := aCollection
]

{ #category : 'as yet unclassified' }
VocReporter >> uniqueMethods [
	
	| res | 
	res := OrderedCollection new. 
	"we should count the number of method with the same name and return 
	only the ones that are uniquely named. "
	matchedPackages do: [ :each | res addAll: each methods ].
	^ res 
]
