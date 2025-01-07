"
""VocReporter is a utility class that analyzes and reports information about Smalltalk packages. 
It focuses on identifying packages that match specific patterns, computing metrics such as the ratio 
of classes to matched packages, and extracting method and class information from these packages. 
It serves as a key component in the Vocanalyzer framework for package analysis.""


Some Examples :

```
PackageOrganizer default packageNamed: 'Athens-Cairo'
```

```
(PackageOrganizer default packageNamed: 'Athens-Cairo') methods groupedBy: [:m | m selector ]
```

```
((PackageOrganizer default packageNamed: 'Athens-Cairo') methods groupedBy: [:m | m selector ]) keys size
```

```
(PackageOrganizer default packageNamed: 'Athens-Cairo') methods size
```

```
(PackageOrganizer default packageNamed: 'Athens-Cairo') methods first ast
```

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
VocReporter >> averageMethodsPerClass [
    "Compute and return the average number of methods per class across all matched packages."

    | totalMethods totalClasses |
    totalMethods := 0.
    self matchedPackages do: [ :pkg | totalMethods := totalMethods + pkg methods size ].
    totalClasses := self numberOfClasses.
    ^ totalClasses = 0 
        ifTrue: [ 0 ]
        ifFalse: [ (totalMethods asFloat / totalClasses) ]
]

{ #category : 'as yet unclassified' }
VocReporter >> classPackageRatio [
	
	^ (self numberOfClasses / self matchedPackages size) asFloat
]

{ #category : 'as yet unclassified' }
VocReporter >> classToMethodRatio [
    "Return the ratio of total classes to total methods. 
     Higher ratio might indicate fewer methods per class on average."

    | totalMethods totalClasses |
    totalMethods := 0.
    self matchedPackages do: [ :pkg | totalMethods := totalMethods + pkg methods size ].
    totalClasses := self numberOfClasses.

    ^ totalMethods = 0 
        ifTrue: [ 0 ]
        ifFalse: [ totalClasses asFloat / totalMethods asFloat ]
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
VocReporter >> largestClassesByMethodCount: topN [
    "Return the topN classes that have the largest number of methods within the matched packages."

    | classSizePairs sorted |
    classSizePairs := OrderedCollection new.
    self matchedPackages do: [ :pkg |
        pkg definedClasses do: [ :class |
            classSizePairs add: {class -> class selectors size}.
        ]
    ].
    "Sort descending by the method count"
    sorted := classSizePairs asArray sort: [ :a :b |
        (a second) > (b second)
    ].
    ^ sorted first: (topN min: sorted size)
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
VocReporter >> methodsPerPackage [
    "Return a dictionary mapping each matched package to the size (count) of its methods."
    
    | dict |
    dict := Dictionary new.
    self matchedPackages do: [ :pkg | 
        dict at: pkg name put: pkg methods size
    ].
    ^ dict
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
