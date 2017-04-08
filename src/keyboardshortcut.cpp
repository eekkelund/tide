/*****************************************************************************
 *
 * Created: 2017 by Eetu Kahelin / eekkelund
 *
 * Copyright 2017 Eetu Kahelin. All rights reserved.
 *
 * This file may be distributed under the terms of GNU Public License version
 * 3 (GPL v3) as defined by the Free Software Foundation (FSF). A copy of the
 * license should have been included with this file, or the project in which
 * this file belongs to. You may also find the details of GPL v3 at:
 * http://www.gnu.org/licenses/gpl-3.0.txt
 *
 * If you have any questions regarding the use of this file, feel free to
 * contact the author of this file, or the owner of the project in which
 * this file belongs to.
*****************************************************************************/

#include "keyboardshortcut.h"

#include <QKeyEvent>
#include <QCoreApplication>


KeyboardShortcut::KeyboardShortcut(QObject *parent)
    : QObject(parent)
    , m_keySequence()
    , m_keypressAlreadySend(false)
{
    qApp->installEventFilter(this);
}

void KeyboardShortcut::setKey(QVariant key)
{
    QKeySequence newKey = key.value<QKeySequence>();
    if(m_keySequence != newKey) {
        m_keySequence = key.value<QKeySequence>();
        emit keyChanged();
    }
}

bool KeyboardShortcut::eventFilter(QObject *obj, QEvent *e)
{
    if(e->type() == QEvent::KeyPress && !m_keySequence.isEmpty()) {

        QKeyEvent *keyEvent = static_cast<QKeyEvent*>(e);

        if (keyEvent->key() >= Qt::Key_Shift && keyEvent->key() <= Qt::Key_Alt) {
            return QObject::eventFilter(obj, e);
        }

        int keyInt = keyEvent->modifiers() + keyEvent->key();

        if(!m_keypressAlreadySend && QKeySequence(keyInt) == m_keySequence) {
            m_keypressAlreadySend = true;
            emit activated();
        }
    }
    else if(e->type() == QEvent::KeyRelease) {
        m_keypressAlreadySend = false;
    }
    return QObject::eventFilter(obj, e);
}
