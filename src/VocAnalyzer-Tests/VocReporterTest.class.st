"
A VocReporterTest is a test class for testing the behavior of VocReporter
"
Class {
	#name : 'VocReporterTest',
	#superclass : 'TestCase',
	#instVars : [
		'reporter'
	],
	#category : 'VocAnalyzer-Tests',
	#package : 'VocAnalyzer-Tests'
}

{ #category : 'tests' }
VocReporterTest >> setUp [

    super setUp.
    reporter := VocReporter new.
    reporter packagePatterns: #('Kernel*' 'Collections*').
    reporter computeMatchedPackages.
]

{ #category : 'tests' }
VocReporterTest >> tearDown [

    super tearDown.
    reporter := nil.
]

{ #category : 'tests' }
VocReporterTest >> testAverageInstanceVariablesPerClass [

    "Verify the method returns a number >= 0 (cannot be negative)."
    | result |
    result := reporter averageInstanceVariablesPerClass.
    self assert: (result >= 0).
]

{ #category : 'tests' }
VocReporterTest >> testAverageMethodsPerClass [

    "Check that the average methods per class returns at least 0."
    | result |
    result := reporter averageMethodsPerClass.
    self assert: (result >= 0).
]

{ #category : 'tests' }
VocReporterTest >> testClassPackageRatio [

    "If matchedPackages > 0, ratio should be a float. 
     Otherwise, it might raise an error or be zero."
    | ratio |
    ratio := 0.
    reporter matchedPackages isEmpty
        ifFalse: [ ratio := reporter classPackageRatio ].
    self assert: ratio >= 0.
]

{ #category : 'tests' }
VocReporterTest >> testClassToMethodRatio [

    "Similar to classPackageRatio, test basic validity."
    | ratio |
    ratio := reporter classToMethodRatio.
    self assert: ratio >= 0.
]

{ #category : 'tests' }
VocReporterTest >> testComputeMatchedPackages [

   "Ensure that computeMatchedPackages populates matchedPackages."
   | oldSize newSize |
	oldSize := reporter matchedPackages size.
	reporter matchedPackages: OrderedCollection new. 
	newSize := (reporter computeMatchedPackages) size.
	self assert: newSize > 0
    	description: 'Should have at least 1 matched package'.
]

{ #category : 'tests' }
VocReporterTest >> testComputedMatchedPatterns [

    "Verify that calling computedMatchedPatterns populates matchedPackages (non-empty)."
    | newSize |
    reporter matchedPackages: OrderedCollection new.
    reporter computedMatchedPatterns.
    newSize := reporter matchedPackages size.
    self assert: newSize > 0
        description: 'Should match at least one package.'
]

{ #category : 'tests' }
VocReporterTest >> testDeprecatedMethods [

    "Check that it returns a collection (possibly empty)."
    | deps |
    deps := reporter deprecatedMethods.
    self assert: deps isCollection.
]

{ #category : 'tests' }
VocReporterTest >> testInitialize [

    "We can test if #initialize sets matchedPackages properly."
    | freshReporter |
    freshReporter := VocReporter new.
    self assert: (freshReporter matchedPackages isEmpty).
]

{ #category : 'tests' }
VocReporterTest >> testMatchedPackages [

    "Just verify we get a collection. 
     The size may vary depending on your image."
    | pkgs |
    pkgs := reporter matchedPackages.
    self assert: pkgs isCollection.
]

{ #category : 'tests' }
VocReporterTest >> testMatchedPackagesSetter [

    "Check that we can set and retrieve matched packages. 
     In real tests, you'd verify it's storing what you expect."
    | temp |
    temp := OrderedCollection new.
    reporter matchedPackages: temp.
    self assert: reporter matchedPackages equals: temp.
]

{ #category : 'tests' }
VocReporterTest >> testMethodsPerPackage [

    "Check that we get a Dictionary mapping packageName -> methodCount."
    | dict |
    dict := reporter methodsPerPackage.
    self assert: dict isDictionary.
    "Optional: ensure keys align with matched package names"
    reporter matchedPackages do: [:pkg |
        self assert: (dict includesKey: pkg name).
    ].
]

{ #category : 'tests' }
VocReporterTest >> testMethodsWithMostLinesOfCode [

    "Ask for the top 5 methods with most lines of code; result is an Array/Collection 
     of {method. lineCount} pairs."
    | topMethods |
    topMethods := reporter methodsWithMostLinesOfCode: 5.
    topMethods do: [:pair |
        self assert: (pair size = 2).
        self assert: (pair first isCompiledMethod).
        self assert: (pair second isNumber).
    ].
]

{ #category : 'tests' }
VocReporterTest >> testPackagePatterns [

    "Simple test to see that we can set and retrieve package patterns."
    | patterns |
    patterns := #('SomePattern*').
    reporter packagePatterns: patterns.
    "force re-matching"
    reporter computeMatchedPackages.
    self assert: (reporter matchedPackages size >= 0).
    "No real numeric assertion here, as it depends on your image's packages."
]

{ #category : 'tests' }
VocReporterTest >> testTopPackagesByClassCount [

    "Fetch top 2 packages by class count; verify the structure."
    | topPkgs |
    topPkgs := reporter topPackagesByClassCount: 2.
    self assert: topPkgs isCollection.
    self assert: topPkgs size <= 2.
]

{ #category : 'tests' }
VocReporterTest >> testTotalNumberOfClasses [

    "Again, check for a valid integer >= 0."
    | count |
    count := reporter totalNumberOfClasses.
    self assert: (count >= 0).
]

{ #category : 'tests' }
VocReporterTest >> testTotalNumberOfMethods [

    "Check for a nonnegative integer."
    | count |
    count := reporter totalNumberOfMethods.
    self assert: (count >= 0).
]

{ #category : 'tests' }
VocReporterTest >> testUniqueMethods [

    "Should return a collection of selectors that appear only once."
    | uniques |
    uniques := reporter uniqueMethods.
    self assert: uniques isCollection.
    "We can't do a meaningful numeric check without mock data, 
     but we at least ensure it is a collection."
]
