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


```
""Create a new instance of VocReporter""
reporter := VocReporter new.

""Set up package patterns to match""
reporter packagePatterns: {'Kernel*'. 'Collections*'}.

""Compute matched packages based on the patterns""
reporter computedMatchedPatterns.

""Now you can use various methods to analyze and report""

""Print the number of matched packages""
reporter matchedPackages size printString, ' packages matched.' traceCr.

""Print the total number of classes in matched packages""
reporter numberOfClasses printString, ' classes found.' traceCr.

""Print the class to package ratio""
('Class to package ratio: ', reporter classPackageRatio printString) traceCr.

""Print average methods per class""
('Average methods per class: ', reporter averageMethodsPerClass printString) traceCr.

""Print methods per package""
'Methods per package:' traceCr.
reporter methodsPerPackage keysAndValuesDo: [:pkg :count |
    (pkg, ': ', count printString) traceCr].

""Print average instance variables per class""
('Average instance variables per class: ', 
 reporter averageInstanceVariablesPerClass printString) traceCr.

""Print top 5 methods with most lines of code""
'Top 5 methods with most lines of code:' traceCr.
(reporter methodsWithMostLinesOfCode: 5) do: [:pair |
    (pair first selector, ' (', pair first methodClass name, '): ', 
     pair second printString, ' lines') traceCr].

""Print number of deprecated methods""
(reporter deprecatedMethods size printString, 
 ' deprecated methods found.') traceCr.


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
VocReporter >> averageCyclomaticComplexity [
    | totalComplexity totalMethods |
    totalComplexity := 0.
    totalMethods := 0.
    self matchedPackages do: [:pkg |
        pkg methods do: [:method |
            totalComplexity := totalComplexity + method cyclomaticComplexity.
            totalMethods := totalMethods + 1]].
    ^ totalMethods = 0
        ifTrue: [0]
        ifFalse: [totalComplexity / totalMethods]
]

{ #category : 'as yet unclassified' }
VocReporter >> averageInstanceVariablesPerClass [
    | totalVars totalClasses |
    totalVars := 0.
    totalClasses := 0.
    self matchedPackages do: [:pkg |
        pkg definedClasses do: [:class |
            totalVars := totalVars + class instVarNames size.
            totalClasses := totalClasses + 1]].
    ^ totalClasses = 0
        ifTrue: [0]
        ifFalse: [totalVars / totalClasses]
]

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
VocReporter >> deprecatedMethods [
    ^ self matchedPackages flatCollect: [:pkg |
        pkg methods select: [:method |
            method pragmas anySatisfy: [:pragma |
                pragma selector = #deprecated]]]
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
VocReporter >> methodsWithMostLinesOfCode: n [
    | methodsWithLines |
    methodsWithLines := OrderedCollection new.
    self matchedPackages do: [:pkg |
        pkg methods do: [:method |
            methodsWithLines add: {method. method sourceCode lines size}]].
    ^ (methodsWithLines sorted: [:a :b | a second > b second])
        first: (n min: methodsWithLines size)
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
VocReporter >> topPackagesByClassCount: n [
    "Return the top n packages with the most classes."
    ^ (self matchedPackages
        sorted: [:a :b | a definedClasses size > b definedClasses size])
        first: (n min: self matchedPackages size)
]

{ #category : 'as yet unclassified' }
VocReporter >> uniqueMethods [
    | methodCounts |
    methodCounts := Dictionary new.
    self matchedPackages do: [:pkg |
        pkg methods do: [:method |
            methodCounts
                at: method selector
                put: (methodCounts at: method selector ifAbsent: [0]) + 1]].
    ^ methodCounts keys select: [:selector |
        (methodCounts at: selector) = 1]
]
