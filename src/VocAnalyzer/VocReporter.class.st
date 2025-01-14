"
""VocReporter is a utility class that analyzes and reports information about Smalltalk packages. 
It focuses on identifying packages that match specific patterns, computing metrics such as the ratio 
of classes to matched packages, and extracting method and class information from these packages. 
It serves as a key component in the Vocanalyzer framework for package analysis.""

To get all the results form one simple code you can run this code:


``` smalltalk
global := VocReporter runAllOnPatterns: {'Kernel*'. 'Collections*'}.
```

Some Examples :

``` smalltalk 
PackageOrganizer default packageNamed: 'Athens-Cairo'

(PackageOrganizer default packageNamed: 'Athens-Cairo') methods groupedBy: [:m | m selector ]

((PackageOrganizer default packageNamed: 'Athens-Cairo') methods groupedBy: [:m | m selector ]) keys size

(PackageOrganizer default packageNamed: 'Athens-Cairo') methods size

(PackageOrganizer default packageNamed: 'Athens-Cairo') methods first ast
```

For More details you can run this code :

``` smalltalk
reporter := VocReporter new.
reporter packagePatterns: {'Kernel*'. 'Collections*'}.
reporter computedMatchedPatterns.
reporter computeMatchedPackages.

""Print matchedpackages""
reporter matchedPackages size printString, ' packages matched.' traceCr.

""Print numbers of classes""
reporter numberOfClasses.
reporter numberOfClasses printString, ' classes found.' traceCr.

""Print average method per class""
reporter averageMethodsPerClass.
('Average methods per class: ', reporter averageMethodsPerClass printString) traceCr.

""Print average instance variables per class""
reporter averageInstanceVariablesPerClass.
('Average instance variables per class: ',  reporter averageInstanceVariablesPerClass printString) traceCr.

""Methods per package""
reporter methodsPerPackage .
'Methods per package:' traceCr. reporter methodsPerPackage keysAndValuesDo: [:pkg :count |(pkg, ': ', count printString) traceCr].

""Class Package Ratio""
reporter classPackageRatio.
('Class to package ratio: ', reporter classPackageRatio printString) traceCr.

""Print number of deprecated methods""
reporter deprecatedMethods.
(reporter deprecatedMethods size printString, ' deprecated methods found.') traceCr.

""Print top 5 methods with most lines of code""
reporter methodsWithMostLinesOfCode: 5.
'Top 5 methods with most lines of code:' traceCr.
(reporter methodsWithMostLinesOfCode: 5) do: [:pair | (pair first selector, ' (', pair first methodClass name, '): ', pair second printString, ' lines') traceCr].

reporter uniqueMethods.




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
VocReporter class >> runAllOnPatterns: patternList [
    "Creates a VocReporter, sets the patterns, computes the matched packages,
    collects the results in a Dictionary, and returns it."

    | reporter results |
    reporter := self new.
    reporter packagePatterns: patternList.
    reporter computeMatchedPackages.

    "Collect everything in a Dictionary, so the caller can navigate it."
    results := reporter gatherAnalysis.

    ^ results
]

{ #category : 'as yet unclassified' }
VocReporter >> argestClassesByMethodCount: topN [

    | classSizePairs sorted |
    classSizePairs := self matchedPackages 
        flatCollect: [ :pkg | 
            pkg definedClasses collect: [ :class | 
                {class -> class selectors size}.
            ] 
        ].
    sorted := classSizePairs asArray sort: [ :a :b | (a second) > (b second) ].
    ^ sorted first: (topN min: sorted size)
]

{ #category : 'as yet unclassified' }
VocReporter >> averageInstanceVariablesPerClass [

    | instVarCounts |
    instVarCounts := self matchedPackages
        flatCollect: [ :pkg | pkg definedClasses collect: [ :class | class instVarNames size ] ].
    ^ instVarCounts isEmpty
        ifTrue: [ 0 ]
        ifFalse: [ instVarCounts sum / instVarCounts size ]
]

{ #category : 'as yet unclassified' }
VocReporter >> averageMethodsPerClass [

    ^ self numberOfClasses = 0
        ifTrue: [ 0 ]
        ifFalse: [ self totalNumberOfMethods asFloat / self numberOfClasses ]
]

{ #category : 'as yet unclassified' }
VocReporter >> classPackageRatio [
	
	^ (self numberOfClasses / self matchedPackages size) asFloat
]

{ #category : 'as yet unclassified' }
VocReporter >> classToMethodRatio [

    | totalMethods totalClasses |
    totalMethods := 0.
    self matchedPackages do: [ :pkg | totalMethods := totalMethods + pkg methods size ].
    totalClasses := self numberOfClasses.

    ^ totalMethods = 0 
        ifTrue: [ 0 ]
        ifFalse: [ totalClasses asFloat / totalMethods asFloat ]
]

{ #category : 'as yet unclassified' }
VocReporter >> computeMatchedPackages [

    self packageOrganizer packageNamesDo: [:pkgName |
        (packagePatterns anySatisfy: [:pat | pat match: pkgName])
            ifTrue: [ matchedPackages add: (self packageOrganizer packageNamed: pkgName) ] ].
    ^ matchedPackages
]

{ #category : 'as yet unclassified' }
VocReporter >> computedMatchedPatterns [
	
	self packageOrganizer packageNamesDo: [ :each | (packagePatterns anySatisfy: [ :pat | pat match: each ])
																	ifTrue: [ matchedPackages add: (self packageOrganizer packageNamed: each) ] ]
]

{ #category : 'as yet unclassified' }
VocReporter >> deprecatedMethods [

    | isDeprecated |
    isDeprecated := [:method | method pragmas anySatisfy: [:pr | pr selector = #deprecated]].
    ^ self matchedPackages
        flatCollect: [:pkg | pkg methods select: isDeprecated]
]

{ #category : 'as yet unclassified' }
VocReporter >> gatherAnalysis [
    "Gather all relevant analysis in a Dictionary and return it."

    ^ Dictionary new
        at: #matchedPackages put: self matchedPackages;
        at: #numberOfPackages put: self matchedPackages size;
        at: #numberOfClasses put: self numberOfClasses;
        at: #averageMethodsPerClass put: self averageMethodsPerClass;
        at: #averageInstanceVariablesPerClass put: self averageInstanceVariablesPerClass;
        at: #methodsPerPackage put: self methodsPerPackage;
        at: #classPackageRatio put: self classPackageRatio;
        at: #deprecatedMethods put: self deprecatedMethods;
        at: #methodsWithMostLinesOfCode put: (self methodsWithMostLinesOfCode: 5);
        at: #uniqueMethods put: self uniqueMethods;
        yourself
]

{ #category : 'as yet unclassified' }
VocReporter >> initialize [

	super initialize.
	matchedPackages := OrderedCollection new.
]

{ #category : 'as yet unclassified' }
VocReporter >> largestClassesByMethodCount: topN [

    | classSizePairs sorted |
    classSizePairs := self matchedPackages flatCollect: [ :pkg |
        pkg definedClasses collect: [ :class | {class -> class selectors size} ].
    ].
    sorted := classSizePairs asArray sort: [ :a :b | (a second) > (b second) ].
    ^ sorted first: (topN min: sorted size)
]

{ #category : 'as yet unclassified' }
VocReporter >> logAnalysis [
    "Prints or logs all key analysis results to Transcript (or uses traceCr, etc.)"

    Transcript show: (self matchedPackages size printString), ' packages matched.'; cr.
    Transcript show: (self numberOfClasses printString), ' classes found.'; cr.

    Transcript show: 'Average methods per class: ', self averageMethodsPerClass printString; cr.
    Transcript show: 'Average instance variables per class: ', self averageInstanceVariablesPerClass printString; cr.

    Transcript show: 'Methods per package:'; cr.
    self methodsPerPackage keysAndValuesDo: [:pkgName :methodCount |
        Transcript show: pkgName , ': ' , methodCount printString; cr
    ].

    Transcript show: 'Class to package ratio: ', self classPackageRatio printString; cr.

    Transcript show: (self deprecatedMethods size printString), ' deprecated methods found.'; cr.

    Transcript show: 'Top 5 methods with most lines of code:'; cr.
    (self methodsWithMostLinesOfCode: 5) do: [:pair | 
        Transcript
            show: pair first selector;
            show: ' (';
            show: pair first methodClass name;
            show: '): ';
            show: pair second printString;
            show: ' lines';
            cr
    ].

    Transcript show: 'Unique methods: ', self uniqueMethods size printString; cr.
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
    methodsWithLines := self matchedPackages
        flatCollect: [:pkg | 
            pkg methods collect: [:method |
                {method. method sourceCode lines size}]].
    ^ methodsWithLines
        sort: [:a :b | a second > b second];
        first: (n min: methodsWithLines size)
]

{ #category : 'as yet unclassified' }
VocReporter >> numberOfClasses [

    ^ self totalNumberOfClasses
]

{ #category : 'as yet unclassified' }
VocReporter >> packagePatterns: aCollection [ 

	packagePatterns := aCollection
]

{ #category : 'as yet unclassified' }
VocReporter >> topPackagesByClassCount: n [

    ^ (self matchedPackages
        sorted: [:a :b | a definedClasses size > b definedClasses size])
        first: (n min: self matchedPackages size)
]

{ #category : 'as yet unclassified' }
VocReporter >> totalNumberOfClasses [

    ^ self matchedPackages
        inject: 0
        into: [:sum :pkg | sum + pkg definedClasses size]
]

{ #category : 'as yet unclassified' }
VocReporter >> totalNumberOfMethods [

    ^ self matchedPackages
        inject: 0
        into: [:sum :pkg | sum + pkg methods size]
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
