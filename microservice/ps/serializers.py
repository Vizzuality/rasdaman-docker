"""Serializers"""


def serialize_greeting(greeting):
    """."""
    return {
        'id': None,
        'type': 'greeting',
        'attributes': {
            'word': greeting.get('word', None),
            'propertyTwo': greeting.get('propertyTwo', None),
            'propertyThree': greeting.get('propertyThree', None),
            'something': greeting.get('something', None),
        }
    }
