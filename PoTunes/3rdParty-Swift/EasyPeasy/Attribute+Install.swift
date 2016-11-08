// The MIT License (MIT) - Copyright (c) 2016 Carlos Vidal
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

/**
    Convenience methods applicable to `Attribute` and subclasses
 */
internal extension Attribute {
    
    /**
        Determines whether the `Attribute` must be installed or not
        depending on the `Condition` closure
        - return boolean determining if the `Attribute` has to be
        applied
     */
    internal func shouldInstall() -> Bool {
        return self.condition?() ?? true
    }
    
    /**
        Checks whether a conflicting `Attribute` has been already applied
        to the `UIView` supplied and if so uninstalls the constraint related
        with such `Attribute`
        - parameter view: `UIView` in which the `Attribute` will be installed
     */
    internal func resolveConflictsOnItem(_ item: Item) {
        // Find conflicting constraints and attributes already installed
        let ownerView = self.ownedBySuperview() ? item.owningView! : item
        let conflictingConstraints = ownerView.constraints.filter { constraint in
            if let attribute = constraint.easy_attribute where attribute =~ self {
                return true
            }
            return false
        }
        
        // Remove conflicting attributes
        let conflictingAttributes = ownerView.attributes.filter { $0 != self && (($0 =~ self) == false) }
        ownerView.attributes = conflictingAttributes
        
        // Deactivate conflicting installed constraints
        NSLayoutConstraint.deactivate(conflictingConstraints)
    }
    
    /**
        Appends the current attribute to the associated object `attributes`
        of the owner `UIView`
        - parameter item: `Item` in which the `Attribute` will be installed
     */
    internal func storeInItem(_ item: Item) {
        // Store the attribute applied in the `ownerView`
        if self.ownedBySuperview() {
            item.owningView?.attributes.append(self)
        }
        else { // Store the attributes applied in `item`
            item.attributes.append(self)
        }
    }
    
    /**
        Determines which `ReferenceAttribute` must be taken as reference
        attribute for the actual Attribute class. Usually is the opposite
        of the one that is going to be installed
        - returns `ReferenceAttribute` to install
     */
    internal func referenceAttributeHelper() -> ReferenceAttribute {
        // If already set return
        if let attribute = self.referenceAttribute {
            return attribute
        }
        
        // If reference view is the superview then return same attribute
        // as `createAttribute`
        if let referenceItem = self.referenceItem where referenceItem === self.createItem?.owningView {
            return self.createAttribute
        }
        
        // Otherwise return the opposite of `createAttribute`
        return self.createAttribute.opposite
    }
    
}

/**
    Convenience methods applicable to `Attribute` and subclasses
 */
internal extension Attribute {
    
    /**
        Helper that creates the equivalent `ReferenceAttribute` for an
        `Attribute` subclass
        - returns: the equivalent `ReferenceAttribute`
     */
    internal func referenceAttributeFromClass() -> ReferenceAttribute {
        switch self {
        case is Width: return .width
        case is Height: return .height
        case is Left: return .left
        case is Right: return .right
        case is Top: return .top
        case is Bottom: return .bottom
        case is Leading: return .leading
        case is Trailing: return .trailing
        case is CenterX: return .centerX
        case is CenterY: return .centerY
        case is FirstBaseline: return .firstBaseline
        case is LastBaseline: return .lastBaseline
        case is LeftMargin: return .leftMargin
        case is RightMargin: return .rightMargin
        case is TopMargin: return .topMargin
        case is BottomMargin: return .bottomMargin
        case is LeadingMargin: return .leadingMargin
        case is TrailingMargin: return .trailingMargin
        case is CenterXWithinMargins: return .centerXWithinMargins
        case is CenterYWithinMargins: return .centerYWithinMargins
        default: return .notAnAttribute
        }
    }
    
}
